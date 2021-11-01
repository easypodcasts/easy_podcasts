defmodule EasypodcastsWeb.ChannelLive.FormComponent do
  use EasypodcastsWeb, :live_component

  alias Easypodcasts.Channels

  @impl true
  def update(%{channel: channel} = assigns, socket) do
    changeset = Channels.change_channel(channel)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    case Channels.create_channel(channel_params) do
      {:ok, _channel} ->
        {:noreply,
         socket
         |> Phoenix.LiveView.assign(socket, :channels, Channels.list_channels())
         |> put_flash(:success, "Channel created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
