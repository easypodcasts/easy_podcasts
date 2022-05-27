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
    <div id={@id}>
      <%= if @show_modal do %>
        <div class="flex fixed top-0 left-0 justify-center w-screen h-screen bg-surface/80 dark:bg-d-surface/80">
          <div class="p-5 mt-10 max-h-52 rounded-md border shadow-2xl xl:mt-24 border-primary bg-surface dark:bg-d-surface">
            <h3 class="text-lg font-medium leading-6 dark:text-d-text-dark">
              <%= gettext("Add New Podcast") %>
            </h3>
            <.form
              let={f}
              for={@changeset}
              id="channel-form"
              phx-submit="save"
              phx-target={@myself}
              phx-page-loading
              class="mt-5 h-4/6"
            >
              <%= error_tag(f, :link) %>
              <div class="flex flex-col justify-between h-full">
                <div class="flex flex-col">
                  <%= url_input(f, :link,
                    phx_hook: "AutoFocus",
                    placeholder: "https://example.podcast.com/rss",
                    class:
                      "rounded border border-primary-light  outline-none py-1 px-3 leading-8 mb-2 focus:ring-2 focus:ring-primary hover:ring-1 hover:ring-primary-light bg-surface shadow-inner"
                  ) %>
                  <spam class="px-1 text-xs dark:text-d-text-dark">
                    <%= gettext("Read about our content policies") %>
                    <a href={"#{Routes.about_index_path(@socket, :index)}#disclaimer"} class="text-primary">
                      <%= gettext("here") %>
                    </a>
                  </spam>
                </div>
                <div class="flex justify-between justify-self-end">
                  <button
                    type="button"
                    phx-click="hide_modal"
                    phx-target={@myself}
                    class="inline-flex items-center py-2 px-4 ml-1 text-sm align-middle rounded border-0 text-text-light bg-cancel hover:bg-cancel-dark"
                  >
                    <%= gettext("Cancel") %>
                  </button>
                  <%= submit(gettext("Save"),
                    phx_disable_with: gettext("Saving..."),
                    class:
                      "border-0 ml-1 px-5 focus:outline-none rounded text-sm bg-primary text-text-light hover:bg-primary-dark"
                  ) %>
                </div>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
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
