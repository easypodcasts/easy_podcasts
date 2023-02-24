defmodule EasypodcastsWeb.DonateLive.Index do
  @moduledoc """
  About view
  """
  use EasypodcastsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:show_modal, false)
      |> assign(:donations, Easypodcasts.Donations.list_donations())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <article class="flex flex-col my-4">
      <div class="flex flex-col justify-start p-6 mx-auto w-full shadow md:w-2/3">
        <h1 class="pb-4 text-xl font-bold text-center">
          Donaciones a Easy Podcasts
        </h1>
        <p>
          <em>Easy Podcasts</em>
          se mantiene gracias a <a href={"#{Routes.about_index_path(@socket, :index)}#contribute"} class="link-primary">
            los esfuerzos de su comunidad
          </a>. Una de las posibles formas de contribuir es mediante donaciones que se utilizan para pagar los servidores que alojan <em> Easy Podcast</em>.
        </p>
        <p>
          Para incluir un nombre junto con la donación puede contactar al equipo de <em>Easy Podcasts</em>
          en el <a href="https://t.me/soporte_easypodcasts" class="link-primary">grupo de soporte</a>
        </p>
        <p class="mt-4">Costo mensual del servidor: <span class="font-bold">450 CUP</span></p>
        <div class="flex flex-col mt-4 md:flex-row md:justify-around">
          <img class="w-72 h-72" src={Routes.static_path(@socket, "/images/ez.jpg")} alt="Código QR para donar con Enzona" />
          <img
            class="mt-4 w-72 h-72 md:mt-0"
            src={Routes.static_path(@socket, "/images/tm.jpg")}
            alt="Código QR para donar con Transfermóvil"
          />
        </div>
        <div class="flex-col mt-4 mb-6 w-full rounded-lg border">
          <span class="flex justify-center self-end p-2 w-full rounded-t-lg text-primary-content bg-primary text-md">
            Donaciones (todas las cantidades en CUP)
          </span>
          <table class="table w-full">
            <thead>
              <tr>
                <th>
                  De
                </th>
                <th>
                  Cantidad
                </th>
              </tr>
            </thead>
            <tbody>
              <%= for donation <- @donations do %>
                <tr>
                  <td class="p-2"><%= donation.from %></td>
                  <td class="p-2"><%= donation.amount %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </article>
    """
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
