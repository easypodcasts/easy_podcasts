defmodule EasypodcastsWeb.ChannelLive.Index do
  @moduledoc """
  Index view
  """
  use EasypodcastsWeb, :live_view

  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.ChannelImage
  alias Easypodcasts.Helpers.{Search, Utils}
  import EasypodcastsWeb.PaginationComponent

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Home")
     |> assign(:show_modal, false)
     |> assign(list_channels(params))}
  end

  @impl true
  def handle_event("search", %{"search" => ""}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.channel_index_path(
           socket,
           :index,
           Keyword.drop(socket.assigns.params, [:search])
         )
     )}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    # We validate here to not overwrite current channels if the search query
    # is invalid
    socket =
      case Search.validate_search(search) do
        %{valid?: true, changes: %{search_phrase: _search_phrase}} ->
          push_patch(socket,
            to:
              Routes.channel_index_path(
                socket,
                :index,
                Keyword.put(socket.assigns.params, :search, search)
              )
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("show_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end

  def handle_event("hide_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_info({:queue_length_changed, queue_length}, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_length: queue_length)
    {:noreply, socket}
  end

  defp list_channels(params) do
    search = params["search"]

    page =
      if params["page"],
        do: String.to_integer(params["page"]),
        else: 1

    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages,
      params: params
    } = Channels.list_channels(search, page)

    page_range = Utils.get_page_range(page, total_pages)

    [
      channels: entries,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0,
      page_range: page_range,
      search: search,
      params: params
    ]
  end
end
