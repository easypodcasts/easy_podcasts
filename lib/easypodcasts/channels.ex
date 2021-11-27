defmodule Easypodcasts.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset

  alias Easypodcasts.Repo
  alias Easypodcasts.Channels.{Channel, ChannelImage}
  alias Easypodcasts.Episodes.{Episode, EpisodeAudio}
  alias Easypodcasts.Helpers.{Search, Utils, Feed}

  require Logger

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels, do: Channel |> Repo.all()

  def search_paginate_channels(search, page) do
    case Search.validate_search(search) do
      %{valid?: true, changes: %{search_phrase: search_phrase}} ->
        Search.search(Channel, search_phrase)

      _ ->
        # This should never happen when searching from the web
        Channel
    end
    |> then(
      &from(c in &1,
        left_join: e in Episode,
        on: c.id == e.channel_id,
        group_by: c.id,
        select_merge: %{episodes: count(e.id)},
        order_by: [desc: c.inserted_at]
      )
    )
    |> Repo.paginate(page: page)
    |> Map.put(:params, search: search, page: page)
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel!(id), do: Repo.get!(Channel, id)

  def get_channel_for_feed!(id) do
    episodes =
      from(e in Episode, where: e.status == :done, order_by: [{:desc, e.publication_date}])

    Channel
    |> Repo.get!(id)
    |> Repo.preload(episodes: episodes)
    |> Map.from_struct()
  end

  def slugify_channel(channel), do: "#{channel.id}-#{Utils.slugify(channel.title)}"

  def get_episodes_url_from_channel(id),
    do:
      from(e in Episode, where: e.channel_id == ^id, select: e.original_audio_url)
      |> Repo.all()

  def get_episodes_url(),
    do:
      from(e in Episode, select: e.original_audio_url)
      |> Repo.all()

  def create_channel(attrs \\ %{}) do
    with {:ok, channel} <- insert_channel(attrs),
         {:ok, _episodes} <- process_channel(channel) do
      if channel.image_url do
        ChannelImage.store({channel.image_url, channel})
      end

      {:ok, channel}
    else
      {:error, %Changeset{} = changeset} ->
        # Some validation errors
        {:error, changeset}

      {:error, channel, msg} ->
        # The channel was created but the episodes weren't
        # or it didn't have any episodes
        delete_channel(channel)
        {:error, msg}
    end
  end

  defp insert_channel(attrs),
    do:
      %Channel{}
      |> Channel.changeset(attrs)
      |> Repo.insert()

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{data: %Channel{}}

  """
  def change_channel(%Channel{} = channel, attrs \\ %{}) do
    Channel.changeset(channel, attrs)
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
  def get_episode!(id), do: Repo.get!(Episode, id)

  def search_paginate_episodes_for(channel_id, search, page) do
    episode_query = from(e in Episode, where: e.channel_id == ^channel_id)

    case Search.validate_search(search) do
      %{valid?: true, changes: %{search_phrase: search_phrase}} ->
        Search.search(episode_query, search_phrase)

      _ ->
        # This should never happen when searching from the web
        episode_query
    end
    |> order_by([{:desc, :publication_date}])
    |> Repo.paginate(page: page)
    |> Map.put(:params, search: search, page: page)
  end

  def filter_episodes_by_updated_at(date) do
    from(e in Episode, where: e.updated_at <= ^date and e.status == :done)
  end

  def create_episodes(episodes), do: Repo.insert_all(Episode, episodes, returning: true)

  def update_episode(%Episode{} = episode, attrs \\ %{}) do
    episode
    |> Changeset.change(attrs)
    |> Repo.update()
  end

  def enqueue_episode(episode_id) do
    episode = get_episode!(episode_id)

    case episode.status do
      :new ->
        update_episode(episode, %{status: :queued})
        :ok

      _ ->
        :error
    end
  end

  def inc_episode_downloads(episode_id) do
    from(e in Episode, update: [inc: [downloads: 1]], where: e.id == ^episode_id)
    |> Repo.update_all([])
  end

  def get_channels_stats() do
    channels = Repo.one(from(c in Channel, select: count(c)))
    episodes = Repo.one(from(e in Episode, select: count(e)))

    latest_episodes =
      Repo.all(
        from(e in Episode, order_by: [{:desc, e.publication_date}], limit: 10, select: e.title)
      )

    latest_processed_episodes =
      Repo.all(
        from(e in Episode,
          where: e.status == :done,
          order_by: [{:desc, e.updated_at}],
          limit: 10,
          select: e.title
        )
      )

    size_stats =
      Repo.one(
        from(e in Episode,
          where: e.status == :done,
          select: %{
            total: count(e),
            original: sum(e.original_size),
            processed: sum(e.processed_size)
          }
        )
      )

    {channels, episodes, size_stats, latest_episodes, latest_processed_episodes}
  end

  def get_channels_for(channels_id) do
    {_, channels} =
      from(c in Channel, where: c.id in ^channels_id, select: %{id: c.id, title: c.title})
      |> Repo.all()
      |> Enum.map_reduce(%{}, fn channel, acc ->
        {channel, Map.put_new(acc, channel.id, channel.title)}
      end)

    channels
  end

  def get_next_episode() do
    with episode = %Episode{} <-
           Repo.one(
             from(e in Episode,
               where: e.status == :queued,
               limit: 1,
               order_by: [{:asc, e.updated_at}]
             )
           ) do
      episode
      |> Changeset.change(%{status: :processing})
      |> Repo.update()
    end
  end

  def save_converted_episode(episode_id, upload, worker_id) do
    episode = get_episode!(episode_id)

    if episode.status == :processing do
      file = %{filename: "episode.opus", path: upload}

      case EpisodeAudio.store({file, episode}) do
        {:ok, _} ->
          size = Utils.get_file_size(upload)
          File.rm("priv/tmp/#{episode_id}")

          episode
          |> Changeset.change(%{status: :done, processed_size: size, worker_id: worker_id})
          |> Repo.update()

        {:error, _} ->
          episode |> Changeset.change(%{status: :queued}) |> Repo.update()
      end
    else
      File.rm("priv/tmp/#{episode_id}")
    end
  end

  def process_all_channels() do
    Logger.info("Processing all channels")

    list_channels()
    |> Enum.each(&process_channel(&1, true))
  end

  def process_channel(channel, process_new_episodes \\ false) do
    Logger.info("Processing channel #{channel.title}")

    with {:ok, feed_data} <- Feed.get_feed_data(channel.link),
         {_, new_episodes = [_ | _]} <- save_new_episodes(channel, feed_data) do
      Logger.info("Channel #{channel.title} has #{length(new_episodes)} new episodes")

      if process_new_episodes do
        Logger.info("Processing audio from new episodes of #{channel.title}")
        Enum.each(new_episodes, &enqueue_episode(&1.id))
      end

      {:ok, new_episodes}
    else
      _ ->
        {:error, channel,
         "We can't process that podcast right now. Please create an issue with the feed url."}
    end
  end

  def save_new_episodes(channel, feed_data) do
    # episode_audio_urls = get_episodes_url_from_channel(channel.id)
    episode_audio_urls = get_episodes_url()

    (feed_data["items"] || [])
    |> Stream.filter(&(&1["enclosures"] && hd(&1["enclosures"])["url"] not in episode_audio_urls))
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
        _ -> DateTime.utc_now()
      end

    %{
      description: item["description"],
      title: item["title"],
      link: item["link"],
      original_audio_url: item["enclosures"] && hd(item["enclosures"])["url"],
      original_size:
        item["enclosures"] &&
          (hd(item["enclosures"])["length"] || "0") |> String.trim() |> String.to_integer(),
      channel_id: channel_id,
      publication_date: publication_date,
      feed_data: item
    }
  end
end
