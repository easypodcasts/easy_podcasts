defmodule Easypodcasts.Workers do
  @moduledoc """
  The Workers context.
  """

  import Ecto.Query, warn: false
  alias Easypodcasts.Repo
  alias Ecto.Changeset

  alias Easypodcasts.Workers.Worker

  @doc """
  Returns the list of workers.

  ## Examples

      iex> list_workers()
      [%Worker{}, ...]

  """
  def list_workers do
    Repo.all(Worker)
  end

  @doc """
  Gets a single worker.

  Raises `Ecto.NoResultsError` if the Worker does not exist.

  ## Examples

      iex> get_worker!(123)
      %Worker{}

      iex> get_worker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_worker!(id), do: Repo.get!(Worker, id)

  @doc """
  Creates a worker.

  ## Examples

      iex> create_worker(%{field: value})
      {:ok, %Worker{}}

      iex> create_worker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_worker(attrs \\ %{}) do
    {:ok, worker} =
      %Worker{}
      |> Worker.changeset(attrs)
      |> Repo.insert()

    token = Phoenix.Token.sign(EasypodcastsWeb.Endpoint, "worker auth", worker.id)
    worker |> Changeset.change(%{token: token}) |> Repo.update()
  end

  @doc """
  Updates a worker.

  ## Examples

      iex> update_worker(worker, %{field: new_value})
      {:ok, %Worker{}}

      iex> update_worker(worker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_worker(%Worker{} = worker, attrs) do
    worker
    |> Worker.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a worker.

  ## Examples

      iex> delete_worker(worker)
      {:ok, %Worker{}}

      iex> delete_worker(worker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_worker(%Worker{} = worker) do
    Repo.delete(worker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking worker changes.

  ## Examples

      iex> change_worker(worker)
      %Ecto.Changeset{data: %Worker{}}

  """
  def change_worker(%Worker{} = worker, attrs \\ %{}) do
    Worker.changeset(worker, attrs)
  end

  def is_active(worker_id) do
    worker = get_worker!(worker_id)
    worker.active
  end
end
