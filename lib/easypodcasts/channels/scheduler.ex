defmodule Easypodcasts.Channels.Scheduler do
  use GenServer
  alias Easypodcasts.Channels.DataProcess

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    process_new_episodes = true
    Easypodcasts.Channels.DataProcess.update_all_channels(process_new_episodes)
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # In 12 hours
    Process.send_after(self(), :work, 12 * 60 * 60 * 1000)
  end
end
