defmodule EasypodcastsWeb.QueueComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use EasypodcastsWeb, :live_component

  alias Phoenix.PubSub
  alias Easypodcasts.Channels.DataProcess

  @impl true
  def mount(socket) do
    if connected?(socket), do: PubSub.subscribe(Easypodcasts.PubSub, "queue_state")
    {:ok, socket}
  end

  @impl true
  def update(_assigns, socket) do
    {:ok, assign(socket, :queue_len, DataProcess.get_queue_len())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <%= if @queue_len > 0 do %>
      <div class="fixed bottom-6 right-6 rounded-lg bg-gray-200 px-3 py-1 text-xl">
        <%= @queue_len %> episodes in queue
      </div>
    <% end %>
    </div>
    """
  end

end
