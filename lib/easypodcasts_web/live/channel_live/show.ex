defmodule EasypodcastsWeb.ChannelLive.Show do
  @moduledoc """
  Channel details view
  """
  use EasypodcastsWeb, :live_view
  use EasypodcastsWeb.{ModalComponent, QueueComponent}
  import EasypodcastsWeb.PaginationComponent

  alias Easypodcasts.{Channels, Episodes}
  alias Easypodcasts.Channels.ChannelImage
  alias Easypodcasts.Episodes.EpisodeAudio
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
      |> assign(:show_player, false)
      |> assign(:page_title, "#{channel.title}")

    {:ok, socket}
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

  def handle_event("play_episode", %{"episode_id" => episode_id}, socket) do
    episode_id = String.to_integer(episode_id)

    socket =
      socket
      |> assign(:show_player, true)
      |> assign(:playing_episode, Map.get(socket.assigns.episodes_map, episode_id))

    {:noreply, socket}
  end

  def handle_event("stop_playing", _params, socket) do
    socket = socket |> assign(:show_player, false) |> assign(:playing_episode, nil)
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
