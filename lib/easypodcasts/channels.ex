defmodule Easypodcasts.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Easypodcasts.Repo

  alias Easypodcasts.Channels.Channel
  alias Easypodcasts.Channels.Episode
  alias Easypodcasts.Channels.DataProcess

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    # Repo.all(Channel)
    Repo.all(
      from(c in Channel,
        join: e in Episode,
        on: c.id == e.channel_id,
        group_by: c.id,
        select_merge: %{episodes: count(e.id)},
      )
    )
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
  def get_channel!(id),
    do:
      Repo.get!(Channel, id)
      |> Repo.preload(episodes: from(e in Episode, order_by: [{:desc, e.inserted_at}]))

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}) do
    result =
      %Channel{}
      |> Channel.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, channel} -> DataProcess.update_channel(channel)
      _ -> nil
    end

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

  alias Easypodcasts.Channels.Episode

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
