defmodule Easypodcasts.Processing.Scheduler do
  use GenServer
  require Logger
  alias Easypodcasts.Processing

  def start_link(_opts) do
    Logger.debug("starting genserver: #{__MODULE__}")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:do_work, state) do
    Logger.debug("handle_info :do_work: #{__MODULE__}")
    Processing.process_all_channels()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Logger.debug("schedule_work: #{__MODULE__}")
    Process.send_after(self(), :do_work, :timer.hours(6))
  end
end
