defmodule Easypodcasts.Queue do
  @moduledoc """
  Episodes queue for processing
  """
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

  def out(can_process_blocked) do
    GenServer.call(@name, {:out, can_process_blocked})
  end

  # Internal Callbacks
  def init(:ok) do
    queue = :queue.new()
    {:ok, queue, {:continue, :get_queued_episodes}}
  end

  def handle_continue(:get_queued_episodes, _state) do
    Logger.info("#{@name} getting queued episodes from database")

    {:noreply, :queue.from_list(Episodes.queue_state())}
  end

  def handle_call({:in, episode}, _from, queue) do
    Logger.info("#{@name} adding episode #{episode.id}")
    queue = :queue.in(episode, queue)

    {:reply, :ok, queue}
  end

  def handle_call({:out, true = _can_process_blocked}, _from, queue) do
    {episode, queue} =
      case :queue.out(queue) do
        {:empty, queue} -> {:empty, queue}
        {{:value, episode}, queue} -> {episode, queue}
      end

    Logger.info(
      "#{@name} extracting episode #{if episode != :empty, do: episode.id, else: episode}"
    )

    {:reply, episode, queue}
  end

  def handle_call({:out, false = _can_process_blocked}, _from, queue) do
    {episode, queue} = next_unblocked(queue, :queue.new())

    Logger.info(
      "#{@name} extracting episode #{if episode != :empty, do: episode.id, else: episode}"
    )

    {:reply, episode, queue}
  end

  defp next_unblocked(queue, blocked_episodes) do
    case :queue.out(queue) do
      {:empty, queue} ->
        {:empty, :queue.join(blocked_episodes, queue)}

      {{:value, %{channel: %{blocked: false}} = episode}, queue} ->
        {episode, :queue.join(blocked_episodes, queue)}

      {{:value, %{channel: %{blocked: true}} = episode}, queue} ->
        next_unblocked(queue, :queue.in(episode, blocked_episodes))
    end
  end
end
