defmodule Easypodcasts.Processing.WorkerManager do
  alias Easypodcasts.Channels
  alias Easypodcasts.Processing.Queue
  use GenServer
  require Logger

  @name __MODULE__

  @doc false
  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: @name)

  @impl true
  def init(state) do
    schedule_rescue_episode()
    {:ok, state}
  end

  def next_episode do
    GenServer.call(@name, :next_episode)
  end

  def save_converted_episode(episode_id, upload) do
    GenServer.cast(@name, {:save_converted, {episode_id, upload}})
  end

  @impl true
  def handle_call(:next_episode, _from, state) do
    Logger.info("Giving episode to worker")

    episode =
      case Channels.get_next_episode() do
        {:ok, episode} -> %{id: episode.id, url: episode.original_audio_url}
        _ -> :noop
      end

    {:reply, episode, state}
  end

  @impl true
  def handle_cast({:save_converted, {episode_id, upload}}, state) do
    Logger.info("Saving episode audio")
    Channels.save_converted_episode(episode_id, upload)
    {:noreply, state}
  end

  @impl true
  def handle_info(:rescue_episode, state) do
    case Channels.get_next_episode() do
      {:ok, episode} -> Queue.add_episode(episode)
      _ -> :noop
    end

    {:noreply, state}
  end

  defp schedule_rescue_episode() do
    if Mix.env() == :prod do
      Process.send_after(self(), :rescue_episode, :timer.minutes(3))
    end
  end
end
