defmodule EasypodcastsWeb.ServerLive.Index do
  @moduledoc """
   Server status view
  """
  use EasypodcastsWeb, :live_view
  alias Phoenix.PubSub
  alias Easypodcasts.Episodes
  alias Easypodcasts.Workers
  alias Easypodcasts.Channels
  alias Easypodcasts.Helpers.Utils

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        PubSub.subscribe(Easypodcasts.PubSub, "queue_state")
        asign_tasks(socket)
      else
        socket
      end

    socket =
      socket
      |> assign(:show_modal, false)
      |> assign(:disk_capacity, nil)
      |> assign(:disk_used, nil)
      |> assign(:episodes, nil)
      |> assign(:channels, nil)
      |> assign(:latest_episodes, nil)
      |> assign(:latest_processed_episodes, nil)
      |> assign(:size, nil)
      |> assign(:workers, nil)
      |> assign(:queued_episodes, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="flex flex-col mt-4 mb-6">
      <div class="flex-col mb-6 rounded-lg border">
        <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
          <%= gettext("Queue") %>
        </span>

        <%= if @queued_episodes do %>
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
        <% else %>
          Loading...
        <% end %>
      </div>
      <div class="flex-col mb-6 w-full rounded-lg border">
        <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
          <%= gettext("Latest Episodes") %>
        </span>
        <%= if @latest_episodes do %>
          <ol class="px-7 list-decimal">
            <%= for episode <- @latest_episodes do %>
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
        <% else %>
          Loading...
        <% end %>
      </div>
      <div class="flex-col mb-6 w-full rounded-lg border">
        <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
          <%= gettext("Latest Processed") %>
        </span>
        <%= if @latest_processed_episodes do %>
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
        <% else %>
          Loading...
        <% end %>
      </div>
      <div class="flex">
        <div class="flex-col mb-6 w-1/2 rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            <%= gettext("Podcasts") %>
          </span>

          <ul class="p-2">
            <li>
              <%= gettext("Total Podcasts:") %>
              <%= if @channels do %>
                <%= @channels %>
              <% else %>
                Loading...
              <% end %>
            </li>
            <li>
              <%= gettext("Total Episodes:") %>
              <%= if @episodes do %>
                <%= @episodes %>
              <% else %>
                Loading...
              <% end %>
            </li>
            <li>
              <%= gettext("Original Size:") %>
              <%= if @size && @size.original do %>
                <%= Float.floor(@size.original / 1_000_000_000, 2) %> GB
              <% else %>
                Loading...
              <% end %>
            </li>
            <li>
              <%= gettext("Processed Episodes:") %>
              <%= if @size do %>
                <%= @size.total %>
              <% else %>
                Loading...
              <% end %>
            </li>
            <li>
              <%= gettext("Processed Size:") %>
              <%= if @size && @size.processed do %>
                <%= Float.floor(@size.processed / 1_000_000_000, 2) %> GB
              <% else %>
                Loading...
              <% end %>
            </li>
          </ul>
        </div>
        <div class="flex-col mb-6 w-1/2 rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            <%= gettext("Storage") %>
          </span>
          <ul class="p-2">
            <li>
              <%= gettext("Disk Capacity:") %>
              <%= if @disk_capacity do %>
                <%= Float.floor(@disk_capacity / 1_000_000, 2) %> GB
              <% else %>
                Loading...
              <% end %>
            </li>
            <li>
              <%= gettext("Used:") %>
              <%= if @disk_used do %>
                <%= @disk_used %> GB %
              <% else %>
                Loading...
              <% end %>
            </li>
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
            <%= if @workers do %>
              <%= for worker <- @workers do %>
                <tr>
                  <td class="p-2"><%= worker.name %></td>
                  <td class="p-2"><%= worker.episodes %></td>
                  <td class="p-2"><%= worker.last_episode_processed_at %></td>
                </tr>
              <% end %>
            <% else %>
              Loading...
            <% end %>
          </tbody>
        </table>
      </div>
    </section>
    """
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:queue_state_changed, queue_state}, socket) do
    socket = asign_tasks(socket)
    {:noreply, assign(socket, :queued_episodes, queue_state)}
  end

  def handle_info({ref, {capacity, percent}}, socket) when socket.assigns.disk_task.ref == ref do
    {:noreply, assign(socket, disk_task: nil, disk_capacity: capacity, disk_used: percent)}
  end

  def handle_info({ref, count}, socket) when socket.assigns.channels_task.ref == ref do
    {:noreply, assign(socket, channels_task: nil, channels: count)}
  end

  def handle_info({ref, count}, socket) when socket.assigns.episodes_task.ref == ref do
    {:noreply, assign(socket, episodes_task: nil, episodes: count)}
  end

  def handle_info({ref, size}, socket) when socket.assigns.size_task.ref == ref do
    {:noreply, assign(socket, size_task: nil, size: size)}
  end

  def handle_info({ref, latest}, socket) when socket.assigns.latest_episodes_task.ref == ref do
    {:noreply, assign(socket, latest_episodes_task: nil, latest_episodes: latest)}
  end

  def handle_info({ref, latest}, socket)
      when socket.assigns.latest_processed_episodes_task.ref == ref do
    {:noreply,
     assign(socket, latest_processed_episodes_task: nil, latest_processed_episodes: latest)}
  end

  def handle_info({ref, workers}, socket) when socket.assigns.workers_task.ref == ref do
    {:noreply, assign(socket, workers_task: nil, workers: workers)}
  end

  def handle_info({ref, queue}, socket) when socket.assigns.queue_task.ref == ref do
    {:noreply, assign(socket, queue_task: nil, queued_episodes: queue)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp load_disk_status() do
    {_id, capacity, percent} =
      :disksup.get_disk_data()
      |> Enum.filter(fn {disk_id, _size, _percent} ->
        disk_id == ~c"/home/cloud/podcasts-storage"
        # disk_id == ~c"/"
      end)
      |> hd

    {capacity, percent}
  end

  defp load_channels_count do
    Channels.count_channels()
  end

  defp load_episodes_count do
    Episodes.count_episodes()
  end

  defp load_size_stats do
    Episodes.get_size_stats()
  end

  defp load_latest_episodes do
    Episodes.get_latest_episodes()
  end

  defp load_latest_processed_episodes do
    Episodes.get_latest_processed_episodes()
  end

  defp load_queue do
    Episodes.queue_state()
  end

  defp load_workers do
    Workers.get_workers_stats()
  end

  defp asign_tasks(socket) do
    socket
    |> assign(:disk_task, Task.async(fn -> load_disk_status() end))
    |> assign(:channels_task, Task.async(fn -> load_channels_count() end))
    |> assign(:episodes_task, Task.async(fn -> load_episodes_count() end))
    |> assign(:size_task, Task.async(fn -> load_size_stats() end))
    |> assign(:latest_episodes_task, Task.async(fn -> load_latest_episodes() end))
    |> assign(
      :latest_processed_episodes_task,
      Task.async(fn -> load_latest_processed_episodes() end)
    )
    |> assign(:workers_task, Task.async(fn -> load_workers() end))
    |> assign(:queue_task, Task.async(fn -> load_queue() end))
  end
end
