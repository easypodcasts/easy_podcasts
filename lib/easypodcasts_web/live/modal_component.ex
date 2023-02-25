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
  def render(assigns) do
    ~H"""
    <div id={@id} class="modal">
      <.focus_wrap id="modal-focus" class="modal-box">
        <h3 class="text-lg font-bold">
          <%= gettext("Add New Podcast") %>
        </h3>
        <.form :let={f} for={@changeset} id="channel-form" phx-submit="save" phx-target={@myself} phx-page-loading>
          <%= error_tag(f, :link) %>
          <div class="flex flex-col justify-between h-full">
            <div class="flex flex-col my-4">
              <%= url_input(f, :link,
                placeholder: "https://example.podcast.com/rss",
                class: "mb-2 input input-primary"
              ) %>
              <spam class="px-1 text-sm">
                <%= gettext("Read about our content policies") %>
                <a href={~p"/about/#disclaimer"} class="link-primary">
                  <%= gettext("here") %>
                </a>
              </spam>
            </div>
            <div class="modal-action">
              <button type="button" phx-click={JS.remove_class("modal-open", to: "#new-podcast")} class="btn">
                <%= gettext("Cancel") %>
              </button>
              <%= submit(gettext("Save"),
                phx_disable_with: gettext("Saving..."),
                class: "btn btn-primary"
              ) %>
            </div>
          </div>
        </.form>
      </.focus_wrap>
    </div>
    """
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    case Channels.create_channel(channel_params) do
      {:ok, channel} ->
        Process.send_after(self(), :clear_flash, 5000)

        {:noreply,
         socket
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
end
