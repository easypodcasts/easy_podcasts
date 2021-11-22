defmodule EasypodcastsWeb.ModalComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use EasypodcastsWeb, :live_component
  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.Channel
  alias Phoenix.LiveView.JS

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Podcast")
     |> assign(:changeset, Channels.change_channel(%Channel{}))}
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    IO.inspect(socket.assigns)

    case Channels.create_channel(channel_params) do
      {:ok, channel} ->
        Process.send_after(self(), :clear_flash, 5000)

        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> put_flash(:success, "Podcast '#{channel.title}' created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, msg} ->
        {:noreply, socket |> assign(:show_modal, false) |> put_flash(:error, msg)}
    end
  end

  def show_modal(js \\ %JS{}) do
    js
    |> JS.add_class("fixed", to: "#new-podcast-modal")
    |> JS.remove_class("hidden", to: "#new-podcast-modal")
  end

  def hide_modal(js \\ %JS{}) do
    js
    |> JS.add_class("hidden", to: "#new-podcast-modal")
    |> JS.remove_class("fixed", to: "#new-podcast-modal")
  end
end
