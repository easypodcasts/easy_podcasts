defmodule EasypodcastsWeb.QueueComponent do
  @moduledoc """
  Live component to show the queue length
  """
  use EasypodcastsWeb, :live_component

  alias Easypodcasts.Episodes
  alias Phoenix.PubSub

  defmacro __using__(_opts) do
    quote do
      alias EasypodcastsWeb.QueueComponent

      @impl true
      def handle_info({:queue_length_changed, queue_length}, socket) do
        send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_length: queue_length)
        {:noreply, socket}
      end
    end
  end

  @impl true
  def mount(socket) do
    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "queue_length")
    {:ok, socket}
  end

  @impl true
  def update(%{queue_length: queue_length} = _assigns, socket) do
    {:ok, assign(socket, :queue_length, queue_length)}
  end

  @impl true
  def update(_assigns, socket) do
    {:ok, assign(socket, :queue_length, Episodes.queue_length())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @queue_length > 0 do %>
        <div class="fixed right-6 bottom-6 py-1 px-3 text-xl rounded-lg border bg-secondary border-secondary-dark">
          <%= live_redirect("#{@queue_length} episodes in queue",
            to: Routes.server_index_path(@socket, :index),
            class: "hover:text-on-secondary"
          ) %>
        </div>
      <% end %>
    </div>
    """
  end
end
