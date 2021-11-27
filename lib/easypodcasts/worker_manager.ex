defmodule Easypodcasts.WorkerManager do
  alias Easypodcasts.Episodes
  use GenServer
  require Logger

  @name __MODULE__

  @doc false
  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: @name)

  @impl true
  def init(state) do
    {:ok, state}
  end

  def next_episode do
    GenServer.call(@name, :next_episode)
  end

  def save_converted_episode(episode_id, upload, worker_id \\ nil) do
    GenServer.cast(@name, {:save_converted, {episode_id, upload, worker_id}})
  end

  @impl true
  def handle_call(:next_episode, _from, state) do
    Logger.info("Giving episode to worker")

    episode = nil
    # case Channels.get_next_episode() do
    #   {:ok, episode} -> %{id: episode.id, url: episode.original_audio_url}
    #   _ -> :noop
    # end

    {:reply, episode, state}
  end

  @impl true
  def handle_cast({:save_converted, {episode_id, upload, worker_id}}, state) do
    Logger.info("Saving episode audio")
    Episodes.save_converted_episode(episode_id, upload, worker_id)
    {:noreply, state}
  end
end
