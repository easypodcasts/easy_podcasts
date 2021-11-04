defmodule EasypodcastsWeb.ChannelLive.Index do
  use EasypodcastsWeb, :live_view
  alias Phoenix.PubSub

  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.Channel
  alias Easypodcasts.Channels.DataProcess

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "queue_state")

    socket =
      socket
      |> assign(:channels, list_channels())
      |> assign(:queue_len, DataProcess.get_queue_len())

    {:ok, socket}
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
         |> put_flash(:success, "Channel created successfully. Fetching episodes now")
         |> push_redirect(to: Routes.channel_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info(:queue_changed, socket) do
    {:noreply, update(socket, :queue_len, fn _ -> DataProcess.get_queue_len() end)}
  end

  defp list_channels do
    Channels.list_channels()
  end
end
