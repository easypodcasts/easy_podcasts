defmodule EasypodcastsWeb.EpisodeLive.Show do
  @moduledoc """
  Channel details view
  """
  use EasypodcastsWeb, :live_view
  use EasypodcastsWeb.QueueComponent
  alias Easypodcasts.{Channels, Episodes}
  alias Easypodcasts.Channels.ChannelImage
  alias Easypodcasts.Episodes.EpisodeAudio
  alias Easypodcasts.Helpers.Utils
  alias Phoenix.PubSub

  @impl true
  def mount(%{"channel_slug" => channel_slug, "episode_slug" => episode_slug}, _session, socket) do
    [channel_id | _] = String.split(channel_slug, "-")
    [episode_id | _] = String.split(episode_slug, "-")

    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "episode#{episode_id}")

    channel = Channels.get_channel!(channel_id)
    episode = Episodes.get_episode!(episode_id)

    socket =
      socket
      |> assign(:channel, channel)
      |> assign(:episode, episode)
      |> assign(:show_modal, false)
      |> assign(:show_player, false)
      |> assign(:page_title, "#{episode.title}")

    {:ok, socket}
  end

  @impl true
  def handle_event("process_episode", _value, socket) do
    Process.send_after(self(), :clear_flash, 5000)

    episode_id = socket.assigns.episode.id

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
          |> update(:episode, &%{&1 | status: :queued})
          |> put_flash(:info, "The episode is in queue. #{msg}")

        :error ->
          put_flash(socket, :error, "Sorry. That episode can't be processed right now")
      end

    {:noreply, socket}
  end

  def handle_event("play_episode", _value, socket) do
    socket =
      socket
      |> assign(:show_player, true)
      |> assign(:playing_episode, socket.assigns.episode)

    {:noreply, socket}
  end

  def handle_event("stop_playing", _value, socket) do
    socket = socket |> assign(:show_player, false) |> assign(:playing_episode, nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:episode_processing, socket) do
    Process.send_after(self(), :clear_flash, 5000)

    socket =
      socket
      |> put_flash(:info, "The episode is being processed")
      |> update(:episode, &%{&1 | status: :processing})

    {:noreply, socket}
  end

  @impl true
  def handle_info(:episode_processed, socket) do
    Process.send_after(self(), :clear_flash, 5000)
    episode = Episodes.get_episode!(socket.assigns.episode)

    socket =
      socket
      |> put_flash(:success, "The episode was processed successfully")
      |> assign(:episode, episode)

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
