defmodule EasypodcastsWeb.EpisodeLive.Show do
  @moduledoc """
  Channel details view
  """
  use EasypodcastsWeb, :live_view
  alias Easypodcasts.{Channels, Episodes}
  alias Easypodcasts.Episodes.EpisodeAudio
  alias Easypodcasts.Helpers.Utils
  alias Phoenix.PubSub

  @impl true
  def mount(%{"channel_slug" => channel_slug, "episode_slug" => episode_slug}, _session, socket) do
    [channel_id | _] = String.split(channel_slug, "-")
    [episode_id | _] = String.split(episode_slug, "-")

    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "episode#{episode_id}")

    channel = Channels.get_channel(channel_id)
    episode = Episodes.get_episode(episode_id)

    socket =
      case episode do
        nil ->
          socket
          |> put_flash(:error, gettext("The episode does not exist"))
          |> push_redirect(to: ~p"/")

        %Episodes.Episode{} = episode ->
          socket
          |> assign(:channel, channel)
          |> assign(:episode, episode)
          |> assign(:show_modal, false)
          |> assign(:page_title, "#{episode.title}")
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col p-4 xl:flex-row">
      <input type="hidden" value={@episode.id} id="episode-info" />
      <EasypodcastsWeb.ChannelLive.Show.channel_card channel={@channel} socket={@socket} />
      <section class="mt-5 xl:mt-0 xl:w-1/2 body-font">
        <div class="divide-primary/20">
          <.episode_card episode={@episode} socket={@socket} channel={@channel} full_description={true} />
        </div>
      </section>
    </div>
    """
  end

  def episode_card(assigns) do
    ~H"""
    <div class="flex flex-wrap mb-4 md:flex-nowrap xl:py-8 xl:mb-0">
      <div class="flex flex-col w-full">
        <h2 class="mb-2 text-sm font-medium md:text-xl title-font">
          <%= if @socket.view == EasypodcastsWeb.ChannelLive.Show do %>
            <.link navigate={~p"/#{Utils.slugify(@channel)}/#{Utils.slugify(@episode)}"} class="text-primary">
              <%= @episode.title %>
            </.link>
          <% else %>
            <span class="text-primary">
              <%= @episode.title %>
            </span>
          <% end %>
        </h2>
        <div class="flex mb-3">
          <span class="mr-3 text-xs md:text-sm">
            <%= Utils.format_date(@episode.publication_date) %>
          </span>
          <span class="mr-3 text-xs md:text-sm">
            <%= Utils.get_duration(@episode) %>
          </span>
          <span class="mr-3 text-xs md:text-sm">
            <%= if @episode.status == :done do %>
              <%= Float.floor((@episode.processed_size || 0) / 1_000_000, 2) %> MB ( <%= Float.floor(
                (@episode.original_size - (@episode.processed_size || 0)) / 1_000_000,
                2
              ) %> MB less)
            <% else %>
              <%= Float.floor(@episode.original_size / 1_000_000, 2) %> MB
            <% end %>
          </span>
          <span class="mr-3 text-xs md:text-sm">
            <%= "#{gettext("Downloads:")} #{@episode.downloads}" %>
          </span>
        </div>
        <%= if @full_description do %>
          <div class="mb-4 custom-styles">
            <%= if @episode.feed_data["content"] && String.trim(@episode.feed_data["content"]) != ""  do %>
              <%= sanitize(@episode.feed_data["content"] || @episode.description, :basic_html) |> raw %>
            <% else %>
              <%= sanitize(@episode.description, :basic_html) |> raw %>
            <% end %>
          </div>
        <% else %>
          <p class="mb-4 text-sm md:text-base line-clamp-2 md:line-clamp-6">
            <%= sanitize(@episode.description) %>
          </p>
        <% end %>
        <%= if @episode.status == :done do %>
          <div class="flex items-center self-start">
            <button
              class="flex justify-between mr-2 btn btn-primary"
              phx-click="play"
              phx-target="#player"
              phx-value-episode={@episode.id}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="mr-2 w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <%= gettext("Play") %>
            </button>
            <a
              class="flex justify-between btn btn-accent"
              href={EpisodeAudio.url({"episode.mp4", @episode})}
              download={"#{@episode.title}.mp4"}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="mr-1 w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                />
              </svg>
              <%= gettext("Download") %>
            </a>
          </div>
        <% end %>
        <%= if @episode.status == :queued do %>
          <button class="flex self-start cursor-wait btn" disabled>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="mr-1 w-5 h-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
              />
            </svg>
            <%= gettext("Queued") %>
          </button>
        <% end %>
        <%= if @episode.status == :processing do %>
          <button class="flex self-start cursor-wait btn" disabled>
            <svg class="mr-1 -ml-1 w-5 h-5 animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
            <%= gettext("Processing") %>
          </button>
        <% end %>
        <%= if @episode.status == :new and @episode.retries < 3 do %>
          <button
            class="flex justify-between self-start disabled:cursor-wait btn btn-primary"
            phx-click="process_episode"
            phx-value-episode_id={@episode.id}
            phx-disable-with={gettext("Queuing...")}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="mr-1 w-5 h-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"
              />
            </svg>
            <%= gettext("Process Episode") %>
          </button>
        <% end %>
        <%= if @episode.retries >= 3 and @episode.status != :done do %>
          <div class="flex items-center self-start">
            <span class="mt-4 text-red-500"><%= gettext("This episode has failed processing") %></span>
            <a
              class="flex justify-between py-2 px-2 mt-4 ml-1 text-sm rounded border-0 text-primary-content bg-primary hover:bg-primary-dark"
              href={@episode.original_audio_url}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="mr-1 w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                />
              </svg>
              <%= gettext("Original Audio") %>
            </a>
          </div>
        <% end %>
      </div>
    </div>
    """
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
              gettext("Sit and relax"),
              gettext("Go grab a drink"),
              gettext("Do some stretching")
            ])

          socket
          |> update(:episode, &%{&1 | status: :queued})
          |> put_flash(:info, gettext("The episode is in queue. %{msg}", msg: msg))

        :error ->
          put_flash(socket, :error, gettext("Sorry. That episode can't be processed right now"))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:episode_processing, socket) do
    Process.send_after(self(), :clear_flash, 5000)

    socket =
      socket
      |> put_flash(:info, gettext("The episode is being processed"))
      |> update(:episode, &%{&1 | status: :processing})

    {:noreply, socket}
  end

  @impl true
  def handle_info(:episode_processed, socket) do
    Process.send_after(self(), :clear_flash, 5000)
    episode = Episodes.get_episode(socket.assigns.episode)

    socket =
      socket
      |> put_flash(:success, gettext("The episode was processed successfully"))
      |> assign(:episode, episode)

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
