defmodule EasypodcastsWeb.ServerLive.Index do
  @moduledoc """
   Server status view
  """
  use EasypodcastsWeb, :live_view
  alias Phoenix.PubSub
  alias Easypodcasts.Episodes
  alias Easypodcasts.Helpers.Utils

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        PubSub.subscribe(Easypodcasts.PubSub, "queue_state")

        {_id, capacity, percent} =
          :disksup.get_disk_data()
          |> Enum.filter(fn {disk_id, _size, _percent} ->
            disk_id == '/home/cloud/podcasts-storage'
            # disk_id == '/'
          end)
          |> hd

        socket
        |> assign(get_dynamic_assigns(Episodes.queue_state()))
        |> assign(:disk_capacity, capacity)
        |> assign(:show_modal, false)
        |> assign(:disk_used, percent)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="flex flex-col mt-4 mb-6">
      <%= if connected?(@socket) do %>
        <div class="flex-col mb-6 rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            <%= gettext("Queue") %>
          </span>
          <%= if length(@queued_episodes) > 0 do %>
            <ol class="px-2">
              <%= for episode <- @queued_episodes do %>
                <li class="text-primary">
                  <.link navigate={~p"/#{Utils.slugify(episode.channel)}/#{Utils.slugify(episode)}"}>
                    <%= if episode.status == :processing do %>
                      <svg
                        class="inline w-5 h-5 animate-spin"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
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
                    <% end %>
                    <%= if episode.status == :queued do %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="inline w-5 h-5"
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
                    <% end %>
                    <%= episode.title %>
                  </.link>
                  (
                  <.link navigate={~p"/#{Utils.slugify(episode.channel)}"}>
                    <%= episode.channel.title %>
                  </.link>
                  )
                </li>
              <% end %>
            </ol>
          <% else %>
            <span class="p-2">
              <%= gettext("No episodes in queue") %>
            </span>
          <% end %>
        </div>
        <div class="flex-col mb-6 w-full rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            <%= gettext("Latest Episodes") %>
          </span>
          <ol class="px-7 list-decimal">
            <%= for episode <- @latest_episodes do %>
              <li class="text-primary">
                <.link navigate={~p"/#{Utils.slugify(episode.channel)}/{Utils.slugify(episode}"}>
                  <%= episode.title %>
                </.link>
                (
                <.link navigate={~p"/#{Utils.slugify(episode.channel)}/{Utils.slugify(episode}"}>
                  <%= episode.channel.title %>
                </.link>
                )
              </li>
            <% end %>
          </ol>
        </div>
        <div class="flex-col mb-6 w-full rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            <%= gettext("Latest Processed") %>
          </span>
          <ol class="px-7 list-decimal">
            <%= for episode <- @latest_processed_episodes do %>
              <li class="text-primary">
                <.link navigate={~p"/#{Utils.slugify(episode.channel)}/#{Utils.slugify(episode)}"}>
                  <%= episode.title %>
                </.link>
                (
                <.link navigate={~p"/#{Utils.slugify(episode.channel)}"}>
                  <%= episode.channel.title %>
                </.link>
                )
              </li>
            <% end %>
          </ol>
        </div>
        <div class="flex">
          <div class="flex-col mb-6 w-1/2 rounded-lg border">
            <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
              <%= gettext("Podcasts") %>
            </span>
            <ul class="p-2">
              <li><%= gettext("Total Podcasts:") %> <%= @channels %></li>
              <li><%= gettext("Total Episodes:") %> <%= @episodes %></li>
              <li><%= gettext("Original Size:") %> <%= Float.floor(@size.original / 1_000_000_000, 2) %> GB</li>
              <li><%= gettext("Processed Episodes:") %> <%= @size.total %></li>
              <li><%= gettext("Processed Size:") %> <%= Float.floor(@size.processed / 1_000_000_000, 2) %> GB</li>
            </ul>
          </div>
          <div class="flex-col mb-6 w-1/2 rounded-lg border">
            <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
              <%= gettext("Storage") %>
            </span>
            <ul class="p-2">
              <li><%= gettext("Disk Capacity:") %> <%= Float.floor(@disk_capacity / 1_000_000, 2) %> GB</li>
              <li><%= gettext("Used:") %> <%= @disk_used %> %</li>
            </ul>
          </div>
        </div>
        <div class="flex-col mb-6 w-full rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            <%= gettext("Workers") %>
          </span>
          <table class="table w-full">
            <thead>
              <tr>
                <th>
                  <%= gettext("Name") %>
                </th>

                <th>
                  <%= gettext("Episodes") %>
                </th>

                <th>
                  <%= gettext("Last Processed At") %>
                </th>
              </tr>
            </thead>
            <tbody>
              <%= for worker <- @workers do %>
                <tr>
                  <td class="p-2"><%= worker.name %></td>
                  <td class="p-2"><%= worker.episodes %></td>
                  <td class="p-2"><%= worker.last_episode_processed_at %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      <% end %>
    </section>
    """
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:queue_state_changed, queue_state}, socket) do
    {:noreply, assign(socket, get_dynamic_assigns(queue_state))}
  end

  defp get_dynamic_assigns(queue_state) do
    {channels, episodes, size, latest_episodes, latest_processed_episodes, workers} =
      Easypodcasts.get_channels_stats()

    [
      queued_episodes: queue_state,
      channels: channels,
      episodes: episodes,
      size: size,
      latest_episodes: latest_episodes,
      latest_processed_episodes: latest_processed_episodes,
      workers: workers
    ]
  end

end
