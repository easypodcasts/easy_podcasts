defmodule EasypodcastsWeb.ChannelLive.Show do
  use EasypodcastsWeb, :live_view
  alias Easypodcasts.Channels.DataProcess

  alias Easypodcasts.Channels

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:channel, Channels.get_channel!(id))}
  end

  @impl true
  def handle_event("process_episode", %{"episode_id" => episode_id}, socket) do
    DataProcess.process_episode(episode_id)
    socket = put_flash(socket, :info, "The episode is in queue")
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Channel"
end
