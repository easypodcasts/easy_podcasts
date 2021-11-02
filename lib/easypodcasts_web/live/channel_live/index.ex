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
    changeset = Channels.change_channel(%Channel{})

    socket
    |> assign(:page_title, "New Channel")
    |> assign(:channel, nil)
    |> assign(:changeset, changeset)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Channels")
    |> assign(:channel, nil)
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    case Channels.create_channel(channel_params) do
      {:ok, _channel} ->
        {:noreply,
         socket
         |> put_flash(:success, "Channel created successfully")
         |> push_redirect(to: Routes.channel_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp list_channels do
    Channels.list_channels()
  end
end
