defmodule EasypodcastsWeb.PlayerLive do
  use EasypodcastsWeb, :live_view
  alias Easypodcasts.{Channels, Episodes}
  alias Easypodcasts.Episodes.EpisodeAudio
  alias Easypodcasts.Channels.ChannelImage
  alias Easypodcasts.Helpers.Utils

  @impl true
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:show, false)
     |> assign(:episode, nil)
     |> assign(:channel, nil), layout: false}
  end

  @impl true
  def handle_event("close", _, socket) do
    socket =
      socket
      |> assign(:show, false)
      |> assign(:episode, nil)
      |> assign(:channel, nil)
      |> push_event("cleanup", %{})

    {:noreply, socket}
  end

  def handle_event("play", %{"episode" => episode_id} = params, socket) do
    episode = Episodes.get_episode!(episode_id)
    channel = Channels.get_channel!(episode.channel_id)

    socket =
      socket
      |> assign(:show, true)
      |> assign(:episode, episode)
      |> assign(:channel, channel)
      |> push_event("play", %{current_time: params["current_time"], episode: episode_id})

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="player-container" phx-hook="PlayerHook">
      <%= if @show do %>
        <section class="flex fixed right-0 bottom-0 flex-col py-2 px-4 w-full shadow shadow-base-content/30 xl:right-5 xl:bottom-5 xl:py-4 xl:w-1/3 xl:rounded-xl bg-base-100 z-50 transition ease-in-out duration-300 opacity-0 scale-80" id="player-element">
          <audio src={EpisodeAudio.url({"episode.opus", @episode})}></audio>
          <div class="flex mb-2">
            <%= live_redirect to: Routes.channel_show_path(@socket, :show, Utils.slugify(@channel)) do %>
              <img
                src={ChannelImage.url({"thumb.webp", @channel}, :thumb)}
                alt={@channel.title}
                class="w-16 h-16 rounded-xl"
              />
            <% end %>
            <div class="flex flex-col flex-1 px-2">
              <span class="font-semibold">
                <%= live_redirect(@episode.title,
                  to: Routes.episode_show_path(@socket, :show, Utils.slugify(@channel), Utils.slugify(@episode)),
                  class: "text-primary"
                ) %>
              </span>
            </div>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-8 h-8 cursor-pointer text-primary"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              phx-click="close"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>
          <div class="flex justify-between">
            <div class="flex flex-col flex-1 py-3 px-2">
              <div class="grid content-center mb-1 w-full h-5 rounded-2xl cursor-pointer" id="progress-wrapper">
                <div class="w-full h-1 rounded-2xl bg-primary/30">
                  <div style="width:0%" id="progress" class="mb-1 h-1 rounded-2xl bg-primary"></div>
                </div>
              </div>
              <div class="flex justify-between">
                <span id="current-time" class="text-primary">
                  0:00
                </span>
                <span class="text-primary">
                  <%= Utils.get_duration(@episode) %>
                </span>
              </div>
            </div>
            <svg
              class="mr-1 -ml-1 w-8 h-8 animate-spin text-primary"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              id="loading"
              viewBox="0 0 24 24"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="hidden w-8 h-8 cursor-pointer text-primary"
              fill="none"
              title={gettext("Play")}
              id="play"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
              />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="hidden w-8 h-8 cursor-pointer text-primary"
              title={gettext("Pause")}
              id="pause"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
        </section>
      <% end %>
    </div>
    """
  end
end
