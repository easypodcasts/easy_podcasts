defmodule Easypodcasts.Workers.Worker do
  @moduledoc """
  Worker schema and genserver
  """
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias Easypodcasts.Episodes

  @name __MODULE__

  schema "workers" do
    field :name, :string
    field :token, :string
    field :active, :boolean
    has_many :episodes, Easypodcasts.Episodes.Episode

    timestamps()
  end

  @doc false
  def changeset(worker, attrs) do
    worker
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  use GenServer, restart: :temporary

  def worker_id(pid) do
    GenServer.call(pid, :worker_id)
  end

  @doc false
  def start_link({episode_id, worker_id}),
    do:
      GenServer.start_link(__MODULE__, {episode_id, worker_id},
        name: {:via, Registry, {WorkerRegistry, episode_id}}
      )

  @impl true
  def init(state) do
    Logger.info("#{@name} starting for #{inspect(state)}")
    Process.send_after(self(), :worker_timeout, :timer.minutes(10))
    {:ok, state}
  end

  @impl true
  def handle_call(:worker_id, _from, {episode_id, worker_id}) do
    {:reply, worker_id, {episode_id, worker_id}}
  end

  @impl true
  def handle_info(:worker_timeout, {episode_id, _worker_id} = state) do
    Logger.info("#{@name} timeout for #{inspect(state)}")
    Episodes.enqueue(episode_id)
    {:stop, :timeout, state}
  end
end
