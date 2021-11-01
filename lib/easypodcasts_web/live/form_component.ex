defmodule EasypodcastsWeb.FormComponent do
  use EasypodcastsWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      phx-target={@myself}
      phx-page-loading>
      <%= live_component @component, @opts %>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
