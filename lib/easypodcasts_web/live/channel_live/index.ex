defmodule EasypodcastsWeb.ChannelLive.Index do
  use EasypodcastsWeb, :live_view

  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.Channel
  import EasypodcastsWeb.PaginationComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, get_pagination_assigns())}
  end

  @impl true
  def handle_params(%{"page" => page}, _, socket) do
    {:noreply, assign(socket, get_pagination_assigns(page))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Channel")
    |> assign(:changeset, Channels.change_channel(%Channel{}))
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Home")
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
  def handle_event("search", %{"search" => search}, socket) do
    case Channels.search_channels(search) do
      :noop -> {:noreply, socket}
      channels -> {:noreply, assign(socket, :channels, channels)}
    end
  end

  @impl true
  def handle_info(:queue_changed, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state")
    {:noreply, socket}
  end

  defp get_pagination_assigns(page \\ nil) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Channels.paginate_channels(page: page)

    [
      channels: entries,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0
    ]
  end
end
