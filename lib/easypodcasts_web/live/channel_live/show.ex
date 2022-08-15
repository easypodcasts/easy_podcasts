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

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, list_episodes_for(socket.assigns.channel.id, params))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col p-4 pt-5 divide-y-2 xl:flex-row divide-primary/20">
      <.channel_card channel={@channel} socket={@socket} />
      <section class="mt-5 xl:mt-0 xl:w-1/2 body-font">
        <div class="divide-y-2 divide-primary/20">
          <%= for episode_id <- @episodes_index do %>
            <EasypodcastsWeb.EpisodeLive.Show.episode_card
              episode={Map.get(@episodes_map, episode_id)}
              socket={@socket}
              channel={@channel}
              full_description={false}
            />
          <% end %>
        </div>
      </section>
    </div>
    <%= if @total_pages > 1 and @total_entries > 0 do %>
      <.pagination
        socket={@socket}
        page_number={@page_number}
        total_pages={@total_pages}
        page_range={@page_range}
        route={&Routes.channel_show_path/4}
        action={:show}
        object_id={Utils.slugify(@channel)}
        search={@search}
      />
    <% end %>
    """
  end

  def channel_card(assigns) do
    ~H"""
    <section class="flex relative top-2 flex-col items-center self-center w-full xl:sticky xl:self-start xl:w-1/2 body-font">
      <div class="flex flex-col self-center pb-2 h-auto xl:w-2/3">
        <div class="flex md:flex-col">
          <img
            alt={@channel.title}
            class="mr-2 w-auto h-32 rounded-lg md:mr-0 md:mb-2 md:w-auto bg-placeholder-big grow-1 md:h-[400px] md:max-w-[400px]"
            src={ChannelImage.url({"original.webp", @channel}, :original)}
          />
          <div class="flex flex-col">
            <%= live_redirect(@channel.title,
              to: Routes.channel_show_path(@socket, :show, Utils.slugify(@channel)),
              class: "p-1 text-xl md:p-0 text-primary"
            ) %>
            <div class="mt-2">
              <%= for category <- @channel.categories do %>
                <%= live_redirect("##{category}",
                  to: Routes.channel_index_path(@socket, :index, search: "##{category}"),
                  class: "text-primary"
                ) %>
              <% end %>
            </div>
          </div>
        </div>

        <p class="mt-2 title-font text-md dark:text-d-text-dark">
          <%= sanitize(@channel.description) %>
        </p>
        <button
          phx-click={JS.remove_class("hidden", to: "#subscribe-modal")}
          class="flex justify-between items-center self-start py-1 px-2 mt-4 text-lg font-semibold rounded xl:self-start text-text-light bg-primary hover:bg-primary-dark"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 5c7.18 0 13 5.82 13 13M6 11a7 7 0 017 7m-6 0a1 1 0 11-2 0 1 1 0 012 0z"
            />
          </svg>
          <span class="ml-1">
            <%= gettext("Subscribe") %>
          </span>
        </button>
      </div>
      <div
        id="subscribe-modal"
        class="flex hidden fixed top-0 left-0 justify-center w-screen h-screen bg-surface/80 dark:bg-d-surface/80"
        phx-hook="CopyHook"
      >
        <div class="p-5 mt-10 max-h-56 rounded-md border shadow-2xl md:w-1/3 xl:mt-24 border-primary bg-surface dark:bg-d-surface">
          <h3 class="mb-2 text-lg font-medium leading-6 dark:text-d-text-dark">
            <%= gettext("Subscribe to this podcast") %>
          </h3>

          <a href={"pcast://easypodcasts.live#{Routes.feed_path(@socket, :feed, Utils.slugify(@channel))}"}>
            <button class="flex justify-between items-center py-1 px-2 font-semibold rounded xl:self-start text-text-light bg-primary hover:bg-primary-dark">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-6 h-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                />
              </svg>
              <span class="ml-1">
                <%= gettext("Open in app") %>
              </span>
            </button>
          </a>
          <h3 class="mt-2 mb-2 text-lg font-medium leading-6 dark:text-d-text-dark">
            <%= gettext("Or") %>
          </h3>

          <div class="flex flex-row">
            <input
              type="text"
              id="feed-url"
              class="flex-1 px-3 leading-8 rounded border shadow-inner outline-none hover:ring-1 focus:ring-2 border-primary-light bg-surface hover:ring-primary-light focus:ring-primary"
              value={"https://easypodcasts.live#{Routes.feed_path(@socket, :feed, Utils.slugify(@channel))}"}
            />
            <button
              id="copy-feed-url"
              class="flex justify-between items-center py-1 px-2 ml-2 font-semibold rounded xl:self-start text-text-light bg-primary hover:bg-primary-dark"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-6 h-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"
                />
              </svg>
              <span class="ml-1">
                <%= gettext("Copy") %>
              </span>
            </button>
          </div>

          <div class="flex justify-between justify-self-end mt-5">
            <button
              type="button"
              phx-click={JS.add_class("hidden", to: "#subscribe-modal")}
              class="inline-flex items-center py-2 px-4 ml-1 text-sm align-middle rounded border-0 text-text-light bg-cancel hover:bg-cancel-dark"
            >
              <%= gettext("Cancel") %>
            </button>
          </div>
        </div>
      </div>
    </section>
    """
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
              gettext("Sit and relax"),
              gettext("Go grab a drink"),
              gettext("Do some stretching")
            ])

          socket
          |> update(:episodes_map, fn episodes ->
            put_in(episodes, [episode_id, :status], :queued)
          end)
          |> put_flash(:info, gettext("The episode is in queue. %{msg}", msg: msg))

        :error ->
          put_flash(socket, :error, gettext("Sorry. That episode can't be processed right now"))
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

  @impl true
  def handle_info(
        {:episode_processing, %{episode_id: episode_id}},
        socket
      ) do
    Process.send_after(self(), :clear_flash, 5000)

    msg =
      case Map.get(socket.assigns.episodes_map, episode_id) do
        nil -> gettext("An episode from this podcast is being processed")
        episode -> gettext("The episode '%{title}' is being processed", title: episode.title)
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
      |> put_flash(
        :success,
        gettext("The episode '%{title}' was processed successfully", title: episode.title)
      )
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
