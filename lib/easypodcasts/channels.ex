defmodule Easypodcasts.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  import Easypodcasts.Channels.Query
  alias Easypodcasts.Repo

  import Easypodcasts.Helpers
  alias Easypodcasts.Helpers.Search
  alias Easypodcasts.Channels.{Channel, Episode}
  alias Easypodcasts.Channels.DataProcess

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

  def search_channels(query) do
    Channel
    |> Search.search(query)
    |> channels_with_episode_count()
    |> Repo.all()
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
  def get_channel!(id) do
    Repo.get!(Channel, id)
    |> Repo.preload(episodes: from(e in Episode, order_by: [{:desc, e.publication_date}]))
  end

  def get_channel_for_feed!(id) do
    episodes =
      from(e in Episode, where: e.status == :done, order_by: [{:desc, e.publication_date}])

    Channel
    |> Repo.get!(id)
    |> Repo.preload(episodes: episodes)
    |> Map.from_struct()
  end

  def slugify_channel(channel), do: "#{channel.id}-#{slugify(channel.title)}"

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}) do
    {:ok, channel} =
      result =
      %Channel{}
      |> Channel.changeset(attrs)
      |> Repo.insert()

    DataProcess.update_channel(channel)
    result
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
end
