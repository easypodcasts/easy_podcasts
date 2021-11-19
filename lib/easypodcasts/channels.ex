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
  def list_channels, do: Channel |> Repo.all()

  def search_paginate_channels(search, page) do
    case Search.validate_search(search) do
      %{valid?: true, changes: %{search_phrase: search_phrase}} ->
        Search.search(Channel, search_phrase)

      _ ->
        # This should never happen when searching from the web
        Channel
    end
    |> channels_with_episode_count()
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

  def slugify_channel(channel), do: "#{channel.id}-#{slugify(channel.title)}"

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
         {:ok, _episodes} <- Processing.process_channel(channel) do
      if channel.image_url do
        ChannelImage.store({channel.image_url, channel})
      end

      {:ok, channel}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
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

  def get_queued_episodes(),
    do: from(e in Episode, where: e.status in [:queued, :processing]) |> Repo.all()

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

    latest_episodes =
      Repo.all(
        from e in Episode, order_by: [{:desc, e.publication_date}], limit: 10, select: e.title
      )

    latest_processed_episodes =
      Repo.all(
        from e in Episode,
          where: e.status == :done,
          order_by: [{:desc, e.updated_at}],
          limit: 10,
          select: e.title
      )

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

  def refresh_feed_data() do
    Repo.all(Channel)
    |> Enum.map(fn channel ->
      {:ok, feed_data} = Processing.Feed.get_feed_data(channel.link)
      {channel, feed_data}
    end)
    |> Enum.each(fn {channel, feed_data} ->
      channel |> change(%{feed_data: Map.drop(feed_data, ["items"])}) |> Repo.update()

      feed_data["items"]
      |> Enum.each(fn item ->
        e =
          from(e in Episode, where: e.original_audio_url == ^hd(item["enclosures"])["url"])
          |> Repo.one()

        if e do
          e
          |> change(%{feed_data: item})
          |> Repo.update()
        end
      end)
    end)
  end
end
