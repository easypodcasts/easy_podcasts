defmodule EasypodcastsWeb.ChannelLive.Index do
  use EasypodcastsWeb, :live_view

  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.Channel

  @impl true
  def mount(_params, _session, socket) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Channels.paginate_channels()

    assigns = [
      channels: entries,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_params(%{"page" => page}, _, socket) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Channels.paginate_channels(page: page)

    assigns = [
      channels: entries,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0
    ]

    {:noreply, assign(socket, assigns)}
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
    |> assign(:page_title, "Home")
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
  def handle_event("search", %{"search-podcasts" => search}, socket) do
    search = search |> String.replace(~r/[^0-9a-zA-Z ]/, "") |> String.trim()

    case search do
      "" -> {:noreply, assign(socket, :channels, Channels.paginate_channels().entries)}
      _ -> {:noreply, assign(socket, :channels, Channels.search_channels(search))}
    end
  end

  @impl true
  def handle_info(:queue_changed, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state")
    {:noreply, socket}
  end
end
