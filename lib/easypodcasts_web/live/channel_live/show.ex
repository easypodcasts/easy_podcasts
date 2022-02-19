defmodule EasypodcastsWeb.ChannelLive.Show do
  @moduledoc """
  Channel details view
  """
  use EasypodcastsWeb, :live_view
  import EasypodcastsWeb.PaginationComponent

  alias Easypodcasts.{Channels, Episodes}
  alias Easypodcasts.Channels.ChannelImage
  alias Easypodcasts.Helpers.{Search, Utils}
  alias Phoenix.PubSub

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    [id | _] = String.split(slug, "-")

    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "channel#{id}")

    channel = Channels.get_channel!(id)

    socket =
      socket
      |> assign(:channel, channel)
      |> assign(:show_modal, false)
      |> assign(:page_title, "#{channel.title}")

    {:ok, socket}
  end

  def channel_card(assigns) do
    ~H"""
    <section class="flex relative top-2 flex-col items-center self-center w-full text-gray-600 xl:sticky xl:self-start xl:w-1/2 dark:text-gray-100 body-font">
      <div class="flex flex-col self-center pb-2 h-auto border-b-2 border-gray-300 md:border-0 xl:w-2/3">
        <img
          alt={@channel.title}
          class="h-96 rounded bg-placeholder-big object-cover"
          src={ChannelImage.url({"original.webp", @channel}, :original)}
        />
        <%= link to: Routes.channel_path(@socket, :feed, Utils.slugify(@channel)),
             class: "self-center xl:self-start" do %>
          <button class="flex justify-between items-center py-2 px-2 mt-4 text-lg font-semibold text-white bg-indigo-500 rounded border-0 xl:self-start dark:bg-blue-400 focus:outline-none">
            <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 32 32">
              <path
                fill="white"
                d="M26.334 32c-0.025-14.351-12.547-26.079-26.334-26.106v-5.894c16.916 0 32 14.394 32 32h-5.666zM21.475 31.998h-5.663c0.019-3.524-1.771-7.468-4.604-10.421-2.817-2.977-7.81-4.853-11.194-4.835v-5.892c10.565 0.228 21.246 10.207 21.461 21.148zM4.016 23.997c2.207 0 3.996 1.791 3.996 4 0 2.208-1.789 3.999-3.996 3.999s-3.996-1.791-3.996-3.999c0-2.209 1.789-4 3.996-4z"
              ></path>
            </svg>
            <span class="ml-1">
              Subscribe
            </span>
          </button>
        <% end %>
        <p class="mt-2 title-font text-md">
          <%= sanitize(@channel.description) %>
        </p>
        <div class="mt-2">
          <%= for category <- @channel.categories do %>
            <%= live_redirect("##{category}",
              to: Routes.channel_index_path(@socket, :index, search: "##{category}"),
              class: "text-indigo-500"
            ) %>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, list_episodes_for(socket.assigns.channel.id, params))}
  end

  @impl true
  def handle_event("process_episode", %{"episode_id" => episode_id}, socket) do
    Process.send_after(self(), :clear_flash, 5000)
    episode_id = String.to_integer(episode_id)

    socket =
      case Episodes.enqueue(episode_id) do
        :ok ->
          msg =
            Enum.random([
              "Sit and relax",
              "Go grab a drink",
              "Do some stretching"
            ])

          socket
          |> update(:episodes_map, fn episodes ->
            put_in(episodes, [episode_id, :status], :queued)
          end)
          |> put_flash(:info, "The episode is in queue. #{msg}")

        :error ->
          put_flash(socket, :error, "Sorry. That episode can't be processed right now")
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => ""}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.channel_show_path(
           socket,
           :show,
           Utils.slugify(socket.assigns.channel)
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
              Routes.channel_show_path(
                socket,
                :show,
                Utils.slugify(socket.assigns.channel),
                search: search
              )
          )

        _invalid ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event(_, _, socket) do
    # TODO: Find out how to target another live view rendered with live_render
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        {:episode_processing, %{episode_id: episode_id}},
        socket
      ) do
    Process.send_after(self(), :clear_flash, 5000)

    msg =
      case Map.get(socket.assigns.episodes_map, episode_id) do
        nil -> "An episode from this podcast is being processed"
        episode -> "The episode '#{episode.title}' is being processed"
      end

    socket =
      socket
      |> put_flash(:info, msg)
      |> update(:episodes_map, fn episodes ->
        put_in(episodes, [episode_id, :status], :processing)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        {:episode_processed, %{episode_id: episode_id}},
        socket
      ) do
    Process.send_after(self(), :clear_flash, 5000)
    episode = Episodes.get_episode!(episode_id)

    socket =
      socket
      |> put_flash(:success, "The episode '#{episode.title}' was processed successfully")
      |> update(:episodes_map, fn episodes -> put_in(episodes, [episode_id], episode) end)

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp list_episodes_for(channel_id, params) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Episodes.list_episodes(channel_id, params)

    {episodes_index, episodes_map} = episodes_from_list(entries)

    page_range = Utils.get_page_range(params["page"] || 0, total_pages)

    [
      episodes_index: episodes_index,
      episodes_map: episodes_map,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0,
      page_range: page_range,
      search: params["search"],
      params: Utils.map_to_keywordlist(params, ~w(page search))
    ]
  end

  defp episodes_from_list(episodes) do
    {_, episodes_map} =
      Enum.map_reduce(episodes, %{}, fn entry, acc ->
        {entry, Map.put_new(acc, entry.id, entry)}
      end)

    episodes_index = Enum.map(episodes, & &1.id)
    {episodes_index, episodes_map}
  end
end
