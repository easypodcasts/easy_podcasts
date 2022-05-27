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
     |> assign(:page_title, gettext("Home"))
     |> assign(list_channels(params))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="mx-auto body-font">
      <div class="flex flex-wrap pl-0">
        <%= if @total_entries > 0 do %>
          <%= for channel <- @channels do %>
            <div class="p-2 w-full md:p-4 md:w-1/5">
              <div class="flex w-auto h-full rounded-lg border md:flex-col border-primary">
                <%= live_redirect to: Routes.channel_show_path(@socket, :show, Utils.slugify(channel)) do %>
                  <img
                    class="w-24 rounded-l-lg md:mb-2 md:w-full md:rounded-t-lg xl:object-cover bg-placeholder-small"
                    src={ChannelImage.url({"thumb.webp", channel}, :thumb)}
                    alt={channel.title}
                    loading="lazy"
                  />
                <% end %>
                <p class="flex-1 px-1 h-5/6 text-sm md:px-2 md:mb-2 md:text-center line-clamp-4 md:line-clamp-6 dark:text-d-text-dark">
                  <%= sanitize(channel.description) %>
                </p>
                <%= live_redirect to: Routes.channel_show_path(@socket, :show, Utils.slugify(channel)) do %>
                  <span class="flex justify-center self-end pt-4 pr-1 w-16 h-full text-sm text-center break-words rounded-r-lg border-t md:pt-1 md:pb-2 md:w-full md:rounded-b-lg text-wrap text-text-light bg-primary border-primary hover:bg-primary-dark">
                    <%= ngettext("%{episodes} Episode", "%{episodes} Episodes", channel.episodes, episodes: channel.episodes) %>
                  </span>
                <% end %>
              </div>
            </div>
          <% end %>
        <% else %>
          <div class="w-full text-center">
            <h1 class="mb-4 text-3xl font-medium sm:text-4xl title-font">
              <%= gettext("No podcasts to show") %>
            </h1>
          </div>
        <% end %>
      </div>
    </section>
    <%= if @total_pages > 1 and @total_entries > 0 do %>
      <.pagination
        socket={@socket}
        page_number={@page_number}
        total_pages={@total_pages}
        page_range={@page_range}
        route={&Routes.channel_index_path/3}
        action={:index}
        object_id={nil}
        search={@search}
      />
    <% end %>
    """
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
