defmodule Easypodcasts.Processing.Queue do
  use GenServer
  require Logger
  alias Phoenix.PubSub
  alias Easypodcasts.Processing
  alias Easypodcasts.Channels

  @name __MODULE__

  def start_link(_opts) do
    Logger.debug("starting genserver: #{@name}")
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def get_queue_len do
    Logger.debug("get_queue_len")

    GenServer.call(@name, :get_queue_len)
  end

  def get_queue_state do
    Logger.debug("get_queue_state")

    GenServer.call(@name, :get_queue_state)
  end

  def add_episode(new_episode) do
    Logger.debug("add_episode - Episode: #{inspect(new_episode)}")
    GenServer.call(@name, {:add_episode, new_episode})
  end

  # Internal Callbacks
  def init(:ok) do
    # TODO get pending episodes from the database
    Logger.debug("init (:ok) - Creating empty queue")
    state = {:queue.new(), nil}
    {:ok, state}
  end

  def handle_call({:add_episode, new_episode}, _from, {queue, current_episode} = state) do
    Logger.debug("handle_call (:add_episode) - state: #{inspect(state)}")
    {:ok, new_episode} = Channels.update_episode(new_episode, %{status: :queued})

    state = {queue, current_episode} = {:queue.in(new_episode, queue), current_episode}

    broadcast_queue_changed(:queue.len(queue))
    Logger.debug("handle_call (:add_episode) - pushed episode to queue: #{inspect(queue)}")

    state =
      case current_episode do
        nil -> process_next_in_queue(queue)
        _ -> state
      end

    Logger.debug("handle_call (:add_episode) - new_state: #{inspect(state)}")
    {:reply, :ok, state}
  end

  def handle_call(:get_queue_len, _from, {queue, _current_episode} = state) do
    Logger.debug("handle_call (:get_queue_len) - state: #{inspect(:queue.len(queue))}")
    {:reply, :queue.len(queue), state}
  end

  def handle_call(:get_queue_state, _from, {queue, current_episode} = state) do
    Logger.debug("handle_call (:get_queue_len) - state: #{inspect(state)}")
    {:reply, {:queue.to_list(queue), current_episode}, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, {queue, current_episode}) do
    Logger.debug("handle_info - task tompleted, moving on to next #{inspect(queue)}")

    broadcast_episode_state_change(
      :episode_processed,
      current_episode.channel_id,
      current_episode.id
    )

    {:noreply, process_next_in_queue(queue)}
  end

  def handle_info(msg, state) do
    Logger.debug("handle_info - received message: #{inspect(msg)}")
    {:noreply, state}
  end

  defp process_next_in_queue(queue) do
    Logger.debug("process next - current episode is nil, processing queue: #{inspect(queue)}")

    case :queue.out(queue) do
      {:empty, queue} ->
        Logger.debug("process next - current episode is nil, queue was empty")
        {queue, nil}

      {{:value, episode}, queue} ->
        broadcast_queue_changed(:queue.len(queue))

        broadcast_episode_state_change(
          :episode_processing,
          episode.channel_id,
          episode.id
        )

        Task.Supervisor.async_nolink(Easypodcasts.TaskSupervisor, fn ->
          Processing.process_episode_file(episode)
        end)

        {queue, episode}
    end
  end

  defp broadcast_queue_changed(queue_len) do
    PubSub.broadcast(Easypodcasts.PubSub, "queue_state", {:queue_changed, queue_len})
  end

  defp broadcast_episode_state_change(event, channel_id, episode_id) do
    PubSub.broadcast(
      Easypodcasts.PubSub,
      "channel#{channel_id}",
      {event, %{episode_id: episode_id}}
    )
  end
end
