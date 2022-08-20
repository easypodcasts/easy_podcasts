defmodule Easypodcasts.Episodes do
  @moduledoc """
  The Episodes context.
  """

  import Ecto.Query, warn: false
  alias Easypodcasts.Repo
  alias Phoenix.PubSub

  alias Ecto.Changeset
  alias Easypodcasts.Helpers.{Utils, Search}
  alias Easypodcasts.Episodes.{Episode, EpisodeAudio}
  alias Easypodcasts.{Queue}
  alias Easypodcasts.Workers
  alias Easypodcasts.Workers.Worker

  def list_episodes_guids(channel_id),
    do: Repo.all(from(e in Episode, where: e.channel_id == ^channel_id, select: e.guid))

  def list_episodes_guids(),
    do: Repo.all(from(e in Episode, select: e.guid))

  def list_episodes_for_tag(tag) do
    tags = [tag]

    from(e in Episode,
      join: c in assoc(e, :channel),
      where: e.status == :done,
      where: fragment("? @> ?", c.categories, ^tags),
      order_by: [{:desc, e.updated_at}]
    )
    |> Repo.all()
  end

  def list_episodes_for_channels(channels) do
    from(e in Episode,
      where: e.status == :done,
      where: e.channel_id in ^channels,
      order_by: [{:desc, e.updated_at}]
    )
    |> Repo.all()
  end

  def list_episodes(channel_id, params) do
    episode_query = from(e in Episode, where: e.channel_id == ^channel_id)
    {search, filters, tags} = Search.parse_search_string(params["search"], ~w(status))

    {_, filters} =
      Keyword.get_and_update(filters, :status, fn current_value ->
        if current_value in ["new", "queued", "processing", "done"] do
          {current_value, String.to_existing_atom(current_value)}
        else
          :pop
        end
      end)

    page =
      if params["page"],
        do: String.to_integer(params["page"]),
        else: 0

    query =
      case Search.validate_search(search) do
        %{valid?: true, changes: %{search_phrase: search_phrase}} ->
          Search.search(episode_query, search_phrase)

        _invalid ->
          # This should never happen when searching from the web
          episode_query
      end

    query
    |> where(^filters)
    |> where([e], fragment("? @> ?", e.categories, ^tags))
    |> order_by([{:desc, :publication_date}])
    |> Repo.paginate(page: page)
  end

  def queue_state() do
    Repo.all(
      from(e in Episode,
        where: e.status in [:processing, :queued],
        preload: [:channel],
        order_by: [{:asc, :status}, {:asc, :updated_at}]
      )
    )
  end

  def queue_length() do
    Repo.one(
      from(e in Episode,
        where: e.status in [:processing, :queued],
        select: count(e)
      )
    )
  end

  def query_done_episodes(channel_id) do
    from(e in Episode,
      where: e.status == :done and e.channel_id == ^channel_id,
      order_by: [{:desc, e.publication_date}]
    )
  end

  def list_episodes_updated_before(date) do
    from(e in Episode, where: e.updated_at <= ^date and e.status == :done)
  end

  @doc """
  Gets a single episode.

  Raises `Ecto.NoResultsError` if the Episode does not exist.

  ## Examples

      iex> get_episode!(123)
      %Episode{}

      iex> get_episode!(456)
      ** (Ecto.NoResultsError)

  """
  def get_episode!(id) do
    Repo.one(
      from(e in Episode,
        where: e.id == ^id,
        preload: [:channel]
      )
    )
  end

  def create_episodes(episodes), do: Repo.insert_all(Episode, episodes, returning: true)

  def update_episode(%Episode{} = episode, attrs \\ %{}) do
    episode
    |> Changeset.change(attrs)
    |> Repo.update()
  end

  def inc_episode_downloads(episode_id) do
    Repo.update_all(
      from(e in Episode, update: [inc: [downloads: 1]], where: e.id == ^episode_id),
      []
    )
  end

  def inc_episode_retries(episode_id) do
    Repo.update_all(
      from(e in Episode, update: [inc: [retries: 1]], where: e.id == ^episode_id),
      []
    )
  end

  def enqueue(episode_id) do
    episode = get_episode!(episode_id)

    if episode.status in [:new, :processing] and episode.retries < 3 do
      {:ok, episode} = update_episode(episode, %{status: :queued})
      Queue.in_(episode)
      broadcast_queue_changed()
      :ok
    else
      update_episode(episode, %{status: :new, retries: 0})
      :error
    end
  end

  def next_episode(worker) do
    case Queue.out(worker.can_process_blocked) do
      :empty ->
        :noop

      episode ->
        DynamicSupervisor.start_child(
          WorkerSupervisor,
          {Worker, {episode.id, worker.id}}
        )

        {:ok, episode} = update_episode(episode, %{status: :processing})
        inc_episode_retries(episode.id)
        broadcast_queue_changed()
        broadcast_episode_state_change(:episode_processing, episode.channel_id, episode.id)
        %{id: episode.id, url: episode.original_audio_url}
    end
  end

  def converted(episode_id, upload, worker_id) do
    episode = get_episode!(episode_id)

    with pid when is_pid(pid) <- lookup_worker(episode_id),
         {:worker_validation, true} <- {:worker_validation, Worker.worker_id(pid) == worker_id},
         {:ok, _} <- EpisodeAudio.store({%{upload | filename: "episode.opus"}, episode}) do
      size = Utils.get_file_size(upload.path)

      episode
      |> Changeset.change(%{status: :done, processed_size: size, worker_id: worker_id})
      |> Repo.update()

      now = "Etc/UTC" |> DateTime.now!() |> DateTime.truncate(:second)

      worker_id
      |> Workers.get_worker!()
      |> Workers.update_worker(%{last_episode_processed_at: now})

      DynamicSupervisor.terminate_child(WorkerSupervisor, pid)
      broadcast_episode_state_change(:episode_processed, episode.channel_id, episode.id)
      broadcast_queue_changed()
      :ok
    else
      nil ->
        "time for this episode expired"

      {:worker_validation, false} ->
        "this episode was assigned to another worker"

      {:error, _} ->
        enqueue(episode.id)
        "error saving the episode file"
    end
  end

  def cancel(episode_id, worker_id) do
    episode = get_episode!(episode_id)

    pid = lookup_worker(episode_id)

    if pid && Worker.worker_id(pid) == worker_id do
      DynamicSupervisor.terminate_child(WorkerSupervisor, pid)
      enqueue(episode.id)
    end
  end

  # defp valid_episode_duration(_original_path, _converted_path) do
  # true
  # TODO: understand the difference between ffprobe results in client and
  # server

  # original_duration = Utils.get_audio_duration(original_path)
  # converted_duration = Utils.get_audio_duration(converted_path)

  # Logger.info(
  #   "Validating duration of #{original_path} = #{original_duration} vs #{converted_path} = #{converted_duration}"
  # )

  # converted_duration in (original_duration - 60)..(original_duration + 60)
  # end

  defp lookup_worker(id) do
    case Registry.lookup(WorkerRegistry, id) do
      [] ->
        nil

      [{pid, _}] ->
        pid
    end
  end

  defp broadcast_queue_changed() do
    queue = queue_state()

    # PubSub.broadcast(
    #   Easypodcasts.PubSub,
    #   "queue_length",
    #   {:queue_length_changed, length(queue)}
    # )

    PubSub.broadcast(
      Easypodcasts.PubSub,
      "queue_state",
      {:queue_state_changed, queue}
    )
  end

  defp broadcast_episode_state_change(event, channel_id, episode_id) do
    PubSub.broadcast(
      Easypodcasts.PubSub,
      "channel#{channel_id}",
      {event, %{episode_id: episode_id}}
    )

    PubSub.broadcast(
      Easypodcasts.PubSub,
      "episode#{episode_id}",
      event
    )
  end

  def save_new_episodes(channel, feed_data) do
    # episode_audio_urls = get_episodes_url_from_channel(channel.id)
    episodes_guids = list_episodes_guids()

    (feed_data["items"] || [])
    |> Stream.filter(&(&1["enclosures"] && hd(&1["enclosures"])["url"]))
    |> Stream.filter(&(&1["guid"] && &1["guid"] not in episodes_guids))
    |> Stream.map(&episode_item_to_map(&1, channel.id))
    |> Enum.to_list()
    |> create_episodes()
  end

  defp episode_item_to_map(item, channel_id) do
    publication_date =
      with {:ok, parsed_datetime} <- Timex.parse(item["publishedParsed"], "{ISO:Extended}"),
           {:ok, shifted_datetime} <- DateTime.shift_zone(parsed_datetime, "Etc/UTC") do
        shifted_datetime
      else
        _error -> DateTime.utc_now()
      end
    %{
      description: item["description"],
      title: item["title"],
      guid: item["guid"],
      link: item["link"],
      original_audio_url: item["enclosures"] && hd(item["enclosures"])["url"],
      original_size:
        item["enclosures"] &&
          (hd(item["enclosures"])["length"] || "0") |> String.trim() |> String.to_integer(),
      channel_id: channel_id,
      publication_date: publication_date,
      categories:
        Enum.map(item["categories"] || [], fn c ->
          c |> String.replace(" ", "") |> String.downcase()
        end),
      feed_data: item
    }
  end
end

