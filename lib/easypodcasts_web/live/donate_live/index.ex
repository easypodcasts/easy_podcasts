defmodule EasypodcastsWeb.DonateLive.Index do
  @moduledoc """
  About view
  """
  use EasypodcastsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_modal, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <article class="flex flex-col my-4 ">
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
        <div class="flex flex-col md:flex-row md:justify-around mt-4">
          <img class="h-72 w-72" src={Routes.static_path(@socket, "/images/ez.jpg")} alt="Código QR para donar con Enzona" />
          <img class="h-72 w-72 mt-4 md:mt-0" src={Routes.static_path(@socket, "/images/tm.jpg")} alt="Código QR para donar con Transfermóvil" />
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
