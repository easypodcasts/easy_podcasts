defmodule EasypodcastsWeb.ServerLive.Index do
  @moduledoc """
   Server status view
  """
  use EasypodcastsWeb, :live_view
  alias Phoenix.PubSub
  alias Easypodcasts.Episodes
  alias Easypodcasts.Helpers.Utils
  alias EasypodcastsWeb.Presence

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Easypodcasts.PubSub, "queue_state")
      PubSub.subscribe(Easypodcasts.PubSub, "queue_length")
      PubSub.subscribe(Easypodcasts.PubSub, "visitors")
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
      |> assign(:visitors, get_visitors())

    {:ok, socket}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:queue_state_changed, queue_state}, socket) do
    {:noreply, assign(socket, get_dynamic_assigns(queue_state))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, assign(socket, :visitors, get_visitors())}
  end

  defp get_dynamic_assigns(queue_state) do
    {channels, episodes, size, latest_episodes, latest_processed_episodes, workers} =
      Easypodcasts.get_channels_stats()

    [
      queued_episodes: queue_state,
      channels: channels,
      episodes: episodes,
      size: size,
      latest_episodes: latest_episodes,
      latest_processed_episodes: latest_processed_episodes,
      workers: workers
    ]
  end

  defp get_visitors() do
    "visitors" |> Presence.list() |> map_size
  end
end
