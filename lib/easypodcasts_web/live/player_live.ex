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
    {:noreply, socket |> assign(:show, false) |> assign(:episode, nil) |> assign(:channel, nil)}
  end

  def handle_event("play", %{"episode" => episode_id}, socket) do
    episode = Episodes.get_episode!(episode_id)
    channel = Channels.get_channel!(episode.channel_id)

    {:noreply,
     socket |> assign(:show, true) |> assign(:episode, episode) |> assign(:channel, channel)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @show do %>
        <section id="player-element"
          class="flex fixed right-0 bottom-0 flex-col py-2 px-4 w-full bg-white border border-gray-200 shadow-2xl xl:right-5 xl:bottom-5 xl:py-4 xl:w-1/3 xl:rounded-xl"
          phx-hook="PlayerHook"
        >
        <audio src={EpisodeAudio.url({"episode.opus", @episode})}></audio>
          <div class="flex mb-2">
            <img
              src={ChannelImage.url({"thumb.webp", @channel}, :thumb)}
              alt={@channel.title}
              class="w-16 h-16 rounded-xl bg-placeholder-small"
            >
            <div class="flex flex-col flex-1 px-2">
              <span class="hidden mb-2 lg:block">
                <%= @channel.title %>
              </span>
              <span class="font-semibold">
                <%= @episode.title %>
              </span>
            </div>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-8 h-8 text-indigo-500 cursor-pointer"
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
              <div class="mb-1 w-full h-1 bg-indigo-200 rounded-2xl" id="progress-wrapper">
                <div style="width:0%" id="progress" class="mb-1 h-1 bg-indigo-500 rounded-2xl"></div>
              </div>
              <div class="flex justify-between">
                <span id="current-time">
                  0:00
                </span>
                <span>
                  <%= Utils.get_duration(@episode) %>
                </span>
              </div>
            </div>
            <svg
              class="mr-1 -ml-1 w-8 h-8 text-indigo-500 animate-spin"
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
              ></path>
            </svg>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="hidden w-8 h-8 text-indigo-500"
              fill="none"
              title="Play"
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
              class="hidden w-8 h-8 text-indigo-500"
              title="Pause"
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
