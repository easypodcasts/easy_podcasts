defmodule EasypodcastsWeb.ChannelLive.Index do
  use EasypodcastsWeb, :live_view

  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.Channel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :channels, list_channels())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Channel")
    |> assign(:channel, %Channel{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Channels")
    |> assign(:channel, nil)
  end

  defp list_channels do
    Channels.list_channels()
  end
end
