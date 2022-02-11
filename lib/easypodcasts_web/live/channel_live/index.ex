defmodule EasypodcastsWeb.ChannelLive.Index do
  @moduledoc """
  Index view
  """
  use EasypodcastsWeb, :live_view
  use EasypodcastsWeb.{ModalComponent, QueueComponent}

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
           :index
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
                search: search
              )
          )

        _invalid ->
          socket
      end

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp list_channels(params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Channels.list_channels(params)

    page_range = Utils.get_page_range(params["page"] || 0, total_pages)

    [
      channels: entries,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0,
      page_range: page_range,
      search: params["search"],
      params: Utils.map_to_keywordlist(params, ~w(page search))
    ]
  end
end
