defmodule EasypodcastsWeb.ChannelLive.Show do
  use EasypodcastsWeb, :live_view
  import EasypodcastsWeb.PaginationComponent

  alias Easypodcasts.{Channels, ChannelImage, EpisodeAudio}
  import Easypodcasts.Helpers
  alias Phoenix.PubSub

  # @impl true
  # def mount(_params, _session, socket) do
  #   {:ok, socket}
  # end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    [id | _] = String.split(slug, "-")

    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "channel#{id}")

    channel = Channels.get_channel!(id)

    socket =
      socket
      |> assign(:channel, channel)
      |> assign(:show_player, false)
      |> assign(:page_title, "#{channel.title}")

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => _slug, "page" => page}, _, socket) do
    {:noreply, assign(socket, get_pagination_assigns(socket.assigns.channel.id, page))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, assign(socket, get_pagination_assigns(socket.assigns.channel.id))}
  end

  @impl true
  def handle_event("process_episode", %{"episode_id" => episode_id}, socket) do
    Process.send_after(self(), :clear_flash, 5000)
    episode_id = String.to_integer(episode_id)

    socket =
      case Channels.enqueue_episode(episode_id) do
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
  def handle_event("search", %{"search" => ""}, socket),
    do: {:noreply, assign(socket, get_pagination_assigns(socket.assigns.channel.id))}

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    case Channels.search_episodes(socket.assigns.channel.id, search) do
      :noop ->
        {:noreply, socket}

      episodes ->
        {episodes_index, episodes_map} = episodes_from_list(episodes)

        socket =
          socket
          |> assign(:episodes_index, episodes_index)
          |> assign(:episodes_map, episodes_map)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        {:episode_processing, %{episode_id: episode_id}},
        socket
      ) do
    Process.send_after(self(), :clear_flash, 5000)
    episode = Map.get(socket.assigns.episodes_map, episode_id)

    socket =
      socket
      |> put_flash(:success, "The episode '#{episode.title}' is being processed")
      |> update(:episodes_map, fn episodes -> put_in(episodes, [episode_id, :status], :processing) end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        {:episode_processed, %{episode_id: episode_id}},
        socket
      ) do
    Process.send_after(self(), :clear_flash, 5000)
    episode = Channels.get_episode!(episode_id)

    socket =
      socket
      |> put_flash(:success, "The episode '#{episode.title}' was processed successfully")
      |> update(:episodes_map, fn episodes -> put_in(episodes, [episode_id], episode) end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:queue_changed, queue_len}, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_len: queue_len)
    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp get_pagination_assigns(channel_id, page \\ nil) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Channels.paginate_episodes_for(channel_id, page: page)

    {episodes_index, episodes_map} = episodes_from_list(entries)

    page = page || 1
    page_range = get_page_range(page, total_pages)

    [
      episodes_index: episodes_index,
      episodes_map: episodes_map,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0,
      page_range: page_range
    ]
  end

  defp episodes_from_list(episodes) do
    {_, episodes_map} =
      Enum.map_reduce(episodes, %{}, fn entry, acc ->
        {entry, Map.put_new(acc, entry.id, entry)}
      end)

    episodes_index = Enum.map(episodes, fn episode -> episode.id end)
    {episodes_index, episodes_map}
  end

  defp format_date(date) do
    localized = DateTime.shift_zone!(date, "America/Havana")
    Calendar.strftime(localized, "%B %d, %Y")
  end

  defp format_duration(duration) when is_binary(duration) do
    cond do
      String.contains?(duration, ":") -> duration
      true -> format_duration(String.to_integer(duration))
    end
  end

  defp format_duration(duration) when is_integer(duration) do
    time = Time.new!(0, 0, 0) |> Time.add(duration)
    "#{time.hour}:#{time.minute}:#{time.second}"
  end
end
