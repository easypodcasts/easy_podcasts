defmodule Easypodcasts.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Easypodcasts.Repo

  import Easypodcasts.Helpers
  import Easypodcasts.Channels.Query
  alias Easypodcasts.Helpers.Search
  alias Easypodcasts.Channels.{Channel, Episode}
  alias Easypodcasts.Processing
  alias Easypodcasts.Processing.Queue
  alias Easypodcasts.ChannelImage

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    Channel |> channels_with_episode_count() |> Repo.all()
  end

  def paginate_channels(params \\ []) do
    Channel |> channels_with_episode_count() |> Repo.paginate(params)
  end

  def search_channels(search) do
    %{search_phrase: search}
    |> Search.search_changeset()
    |> case do
      %{valid?: true, changes: %{search_phrase: search_phrase}} ->
        Channel
        |> Search.search(search_phrase)
        |> channels_with_episode_count()
        |> Repo.all()

      _ ->
        :noop
    end
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

  def slugify_channel(channel), do: "#{channel.id}-#{slugify(channel.title)}"

  def get_episodes_url_from_channel(id),
    do:
      from(e in Episode, where: e.channel_id == ^id, select: e.original_audio_url)
      |> Repo.all()

  def get_episodes_url(),
    do:
      from(e in Episode, select: e.original_audio_url)
      |> Repo.all()

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}) do
    case %Channel{}
         |> Channel.changeset(attrs)
         |> Repo.insert() do
      {:ok, channel} ->
        # TODO do something when this fails

        ChannelImage.store({channel.image_url, channel})

        Processing.process_channel(channel)
        {:ok, channel}

      result ->
        result
    end
  end

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

  def paginate_episodes_for(channel_id, params \\ []) do
    from(e in Episode, where: e.channel_id == ^channel_id, order_by: [{:desc, e.publication_date}])
    |> Repo.paginate(params)
  end

  def search_episodes(channel_id, search) do
    %{search_phrase: search}
    |> Search.search_changeset()
    |> case do
      %{valid?: true, changes: %{search_phrase: search_phrase}} ->
        from(e in Episode,
          where: e.channel_id == ^channel_id
        )
        |> Search.search(search_phrase)
        |> Repo.all()

      _ ->
        :noop
    end
  end

  def filter_episodes_by_updated_at(date) do
    from(e in Episode, where: e.updated_at <= ^date and e.status == :done)
  end

  def create_episodes(episodes), do: Repo.insert_all(Episode, episodes, returning: true)

  def update_episode(%Episode{} = episode, attrs \\ %{}) do
    episode
    |> change(attrs)
    |> Repo.update()
  end

  def enqueue_episode(episode_id) do
    episode = get_episode!(episode_id)

    case episode.status do
      :new ->
        Queue.add_episode(episode)
        :ok

      _ ->
        :error
    end
  end

  def get_queued_episodes(), do:
  from(e in Episode, where: e.status in [:queued, :processing]) |> Repo.all

  def inc_episode_downloads(episode_id) do
    case episode_id do
      "img" ->
        nil

      episode_id ->
        from(e in Episode, update: [inc: [downloads: 1]], where: e.id == ^episode_id)
        |> Repo.update_all([])
    end
  end

  def get_channels_stats() do
    channels = Repo.one(from c in Channel, select: count(c))
    episodes = Repo.one(from e in Episode, select: count(e))

    size_stats =
      Repo.one(
        from e in Episode,
          where: e.status == :done,
          select: %{
            total: count(e),
            original: sum(e.original_size),
            processed: sum(e.processed_size)
          }
      )

    {channels, episodes, size_stats}
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
end
