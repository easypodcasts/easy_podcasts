defmodule EasypodcastsWeb.QueueComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use EasypodcastsWeb, :live_component

  alias Easypodcasts.Episodes
  alias Phoenix.PubSub

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
      <div class="fixed bottom-6 right-6 rounded-lg bg-gray-200 px-3 py-1 text-xl">
        <%= @queue_length %> episodes in queue
      </div>
    <% end %>
    </div>
    """
  end
end
