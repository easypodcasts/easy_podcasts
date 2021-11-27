defmodule Easypodcasts.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset

  alias Easypodcasts.Repo
  alias Easypodcasts.Channels.{Channel, ChannelImage}
  alias Easypodcasts.Episodes
  alias Easypodcasts.Episodes.Episode
  alias Easypodcasts.Helpers.{Search, Utils, Feed}

  require Logger

  def list_channels, do: Channel |> Repo.all()

  def list_channels(search, page) do
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

  def get_channel!(id), do: Repo.get!(Channel, id)

  def get_channel_for_feed(id) do
    episodes = Episodes.query_done_episodes(id)

    Channel
    |> Repo.get!(id)
    |> Repo.preload(episodes: episodes)
    |> Map.from_struct()
  end

  def slugify_channel(channel), do: "#{channel.id}-#{Utils.slugify(channel.title)}"

  def create_channel(attrs \\ %{}) do
    with {:ok, channel} <-
           %Channel{}
           |> Channel.changeset(attrs)
           |> Repo.insert(),
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

  def get_channels_in(channels_id) do
    {_, channels} =
      from(c in Channel, where: c.id in ^channels_id, select: %{id: c.id, title: c.title})
      |> Repo.all()
      |> Enum.map_reduce(%{}, &{&1, Map.put_new(&2, &1.id, &1.title)})

    channels
  end

  def process_all_channels() do
    Logger.info("Processing all channels")

    list_channels()
    |> Enum.each(&process_channel(&1, true))
  end

  def process_channel(channel, process_new_episodes \\ false) do
    Logger.info("Processing channel #{channel.title}")

    with {:ok, feed_data} <- Feed.get_feed_data(channel.link),
         {_, new_episodes = [_ | _]} <- Episodes.save_new_episodes(channel, feed_data) do
      Logger.info("Channel #{channel.title} has #{length(new_episodes)} new episodes")

      if process_new_episodes do
        Logger.info("Processing audio from new episodes of #{channel.title}")
        Enum.each(new_episodes, &Episodes.enqueue(&1.id))
      end

      {:ok, new_episodes}
    else
      _ ->
        {:error, channel,
         "We can't process that podcast right now. Please create an issue with the feed url."}
    end
  end
end
