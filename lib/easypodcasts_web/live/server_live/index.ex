defmodule EasypodcastsWeb.ServerLive.Index do
  @moduledoc """
   Server status view
  """
  use EasypodcastsWeb, :live_view
  alias Phoenix.PubSub
  alias Easypodcasts.{Channels, Episodes}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Easypodcasts.PubSub, "queue_state")
      PubSub.subscribe(Easypodcasts.PubSub, "queue_length")
    end

    {_id, capacity, percent} =
      :disksup.get_disk_data()
      |> Enum.filter(fn {disk_id, _size, _percent} ->
        disk_id == '/home/cloud/podcasts-storage'
        # disk_id == '/'
      end)
      |> hd

    socket =
      socket
      |> assign(get_dynamic_assigns(Episodes.queue_state()))
      |> assign(:disk_capacity, capacity)
      |> assign(:show_modal, false)
      |> assign(:disk_used, percent)

    {:ok, socket}
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

  def handle_info({:queue_length_changed, queue_length}, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_length: queue_length)
    {:noreply, socket}
  end

  def handle_info({:queue_state_changed, queue_state}, socket) do
    {:noreply, assign(socket, get_dynamic_assigns(queue_state))}
  end

  defp get_dynamic_assigns(queue_state) do
    channels_index =
      queue_state
      |> Enum.map(fn episode -> episode.channel_id end)
      |> Channels.get_channels_in()

    {channels, episodes, size, latest_episodes, latest_processed_episodes} =
      Easypodcasts.get_channels_stats()

    [
      queued_episodes: queue_state,
      channels_index: channels_index,
      channels: channels,
      episodes: episodes,
      size: size,
      latest_episodes: latest_episodes,
      latest_processed_episodes: latest_processed_episodes
    ]
  end
end
