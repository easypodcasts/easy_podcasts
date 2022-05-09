defmodule EasypodcastsWeb.ModalComponent do
  @moduledoc """
  Modal component to show the channel creation form
  """
  use EasypodcastsWeb, :live_component
  alias Easypodcasts.Channels
  alias Easypodcasts.Channels.Channel
  alias Phoenix.LiveView.JS

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Podcast")
     |> assign(:show_modal, false)
     |> assign(:changeset, Channels.change_channel(%Channel{}))}
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    case Channels.create_channel(channel_params) do
      {:ok, channel} ->
        Process.send_after(self(), :clear_flash, 5000)

        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> put_flash(
           :success,
           gettext("Podcast '%{title}' created successfully", title: channel.title)
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, msg} ->
        {:noreply,
         socket
         |> put_flash(:error, msg)
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end

  def handle_event("show_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end

  def handle_event("hide_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
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
