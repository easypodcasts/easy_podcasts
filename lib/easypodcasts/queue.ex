defmodule Easypodcasts.Queue do
  use GenServer
  require Logger
  alias Easypodcasts.Episodes

  @name __MODULE__

  def start_link(_opts) do
    Logger.info("#{@name} starting")
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def in_(episode) do
    GenServer.call(@name, {:in, episode})
  end

  def out() do
    GenServer.call(@name, :out)
  end

  # Internal Callbacks
  def init(:ok) do
    queue = :queue.new()
    {:ok, queue, {:continue, :get_queued_episodes}}
  end

  def handle_continue(:get_queued_episodes, _state) do
    Logger.info("#{@name} getting queued episodes from database")

    {:noreply,
     Episodes.queue_state()
     |> :queue.from_list()}
  end

  def handle_call({:in, episode}, _from, queue) do
    Logger.info("#{@name} adding episode #{episode.id}")
    queue = :queue.in(episode, queue)

    {:reply, :ok, queue}
  end

  def handle_call(:out, _from, queue) do

    {episode, queue} =
      case :queue.out(queue) do
        {:empty, queue} -> {:empty, queue}
        {{:value, episode}, queue} -> {episode, queue}
      end

    Logger.info("#{@name} extracting episode #{if episode != :empty, do: episode.id, else: episode}")
    {:reply, episode, queue}
  end
end
