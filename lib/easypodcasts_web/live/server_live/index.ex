defmodule EasypodcastsWeb.ServerLive.Index do
  use EasypodcastsWeb, :live_view
  alias Phoenix.PubSub
  alias Easypodcasts.Channels
  alias Easypodcasts.Processing.Queue

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "queue_state")

    {_id, capacity, percent} =
      :disksup.get_disk_data()
      |> Enum.filter(fn {disk_id, _size, _percent} ->
        # disk_id == '/home/cloud/podcasts-storage'
        disk_id == '/'
      end)
      |> hd

    socket =
      socket
      |> assign(get_dynamic_assigns())
      |> assign(:disk_capacity, capacity)
      |> assign(:show_modal, false)
      |> assign(:disk_used, percent)

    {:ok, assign(socket, get_dynamic_assigns())}
  end

  @impl true
  def handle_event("show_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end

  def handle_event("hide_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:queue_changed, queue_len}, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_len: queue_len)
    {:noreply, assign(socket, get_dynamic_assigns())}
  end

  defp get_dynamic_assigns() do
    {queue, current_episode} = Queue.get_queue_state()

    channels_index =
      queue
      |> Enum.map(fn episode -> episode.channel_id end)
      |> Channels.get_channels_for()

    {channels, episodes, size, latest_episodes, latest_processed_episodes} =
      Channels.get_channels_stats()

    [
      queue: queue,
      channels_index: channels_index,
      current_episode: current_episode,
      channels: channels,
      episodes: episodes,
      size: size,
      latest_episodes: latest_episodes,
      latest_processed_episodes: latest_processed_episodes
    ]
  end
end
