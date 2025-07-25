defmodule EasypodcastsWeb.AboutLive.Index do
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
    <article class="flex flex-col my-4">
      <div class="flex flex-col justify-start p-6 mx-auto w-full shadow md:w-2/3">
        <h1 class="pb-4 text-xl font-bold text-center">
          Acerca de Easy Podcasts
        </h1>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          ¿Qué es?
        </h2>
        <p>
          <em>Easy Podcasts</em>
          es una solución comunitaria para la descarga de podcasts que tiene como objetivo ayudar a disminuir el consumo de datos: el servicio está alojado en .cu y los archivos de audio son comprimidos. Hecho con
          <span class="text-primary">
            &hearts;
          </span>
          y Software Libre.
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          ¿Cómo lo uso?
        </h2>
        <p>
          Recomendamos usar <em>Easy Podcasts</em>
          mediante una aplicación de podcasts como
          <a class="text-primary" href="https://antennapod.org">
            Antennapod
          </a>
          simplemente adicionando a la aplicación el <em>feed RSS</em>
          del podcast que quieres escuchar.
        </p>
        <p>
          Para comenzar a usar el sistema debes
          <span class="cursor-pointer" phx-click="show_modal">
            añadir
          </span>
          el podcast que quieres escuchar utilizando el enlace a su <em>feed</em>
          o seleccionar uno de los
          <.link navigate={~p"/"} class="text-primary">podcasts existentes</.link>
          y usar el botón para subscribirse.
        </p>
        <p>
          <em>Easy Podcasts</em>
          también cuenta con un reproductor básico integrado aunque recomendamos usar una
          <a class="text-primary" href="https://antennapod.org">
            aplicación nativa
          </a>
          para mejor experiencia.
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          ¿Cuánto cuesta?
        </h2>
        <p>
          <em>Easy Podcasts</em> es gratis.
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          ¿Qué datos recolectan?
        </h2>
        <p>
          <em>Easy Podcasts</em>
          no recolecta datos de usuario de ningún tipo, no tiene soporte para cuentas de usuario y no usa telemetría en el lado del cliente. En el servidor usa
          <a href="https://goaccess.io" class="text-primary">
            GoAccess
          </a>
          para analizar los logs del servidor web
          .
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold" id="contribute">
          ¿Cómo puedo contribuir?
        </h2>
        <p>
          El
          <a href="https://github.com/easypodcasts/easy_podcasts" class="text-primary">
            código fuente de <em>Easy Podcasts</em>
          </a>
          se encuentra disponible bajo una
          <a href="https://www.gnu.org/licenses/agpl-3.0.en.html" class="text-primary">
            licencia de software libre
          </a>
          . Cualquiera es libre de contribuir, copiar, o incluso instalar <em>Easy Podcasts</em>
          en un servidor propio, siempre y cuando se respeten los términos de la licencia.
        </p>
        <p>
          Además de contribuciones directas en el código,
          <a href="https://github.com/easypodcasts/easy_podcasts/issues" class="text-primary">
            los reportes de errores
          </a>
          , <a href="https://t.me/soporte_easypodcasts" class="text-primary">sugerencias y retroalimentación</a>
          general son bienvenidos.
        </p>
        <p>
          La conversión de los episodios se realiza por un
          <a href="https://github.com/easypodcasts/go-worker" class="text-primary">programa externo o <em>worker</em></a>
          que puede ser ejecutado por cualquiera con conocimientos técnicos medios y algún servidor con conexión permanente. Mientras más workers se ejecuten al mismo tiempo más rápido se procesará la cola de episodios a convertir.
        </p>
        <p>
          Por último también es posible contribuir con
          <.link navigate={~p"/donate"} class="link-primary">
            donaciones
          </.link>
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold" id="disclaimer">
          ¿Qué contenido puedo añadir?
        </h2>
        <p>
          Los podcasts que se añaden al sistema están sujetos a la moderación por parte de los administradores.
          <em>Easy Podcasts</em>
          está sujeto a la política de contenidos de nuestro proveedor de hosting, por lo que nos reservamos el derecho de mantener o eliminar cualquier podcast.
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          ¿Qué límites tiene el servicio?
        </h2>
        <p>
          <em>Easy Podcast</em>
          es alojado y mantenido por voluntarios en un servidor de bajas prestaciones por lo que algunos límites en el servicio son necesarios:
        </p>
        <ul class="px-5 list-disc">
          <li>
            La descarga de episodios convertidos no tiene límites aunque puede ralentizarse en dependencia de la carga del servidor.
          </li>
          <li>
            Los episodios son convertidos en dependencia de la disponibilidad de <em>workers</em>
            lo que la prontitud con la que puede obtener un episodio convertido depende de la cantidad de episodios en cola y de
            <em>workers</em>
            que estén disponibles en el momento
            <.link navigate={~p"/status"} class="text-primary">
              El estado de la cola de conversión puede consultarse aquí
            </.link>
          </li>
          <li>
            Según el estado del almacenamiento, los episodios convertidos se irán eliminando comenzando por los que se convirtieron hace más tiempo. Si un episodio convertido se elimina siempre puede convertirse nuevamente.
            <.link navigate={~p"/status"} class="text-primary">
              El estado del almacenamiento puede consultarse aquí
            </.link>
          </li>
          <li>
            Debido a los términos del proveedor de servicios el servidor cuenta con 250GB de tráfico mensual, de superarse este límite
            <em>Easy Podcasts</em>
            dejará de prestar servicios hasta el próximo mes.
          </li>
        </ul>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          ¿Por qué se demora en convertir un episodio?
        </h2>
        <p>
          Los episodios son convertidos en dependencia de la disponibilidad de <em>workers</em>
          lo que la prontitud con la que puede obtener un episodio convertido depende de la cantidad de episodios en cola y de
          <em>workers</em>
          que estén disponibles en el momento.
          <.link navigate={~p"/status"} class="text-primary">
            El estado de la cola de conversión puede consultarse aquí
          </.link>
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          Estoy usando una aplicación de podcasts, ¿por qué no aparecen todos los episodios en el feed?
        </h2>
        <p>En el <em>feed</em> generado por <em>Easy Podcasts</em> aparecen los episodios ya convertidos.</p>
        <p>
          <em>Easy Podcasts</em>
          solo convierte automáticamente los episodios que se publiquen a partir del momento en que un podcast se añade al sistema. Cualquier episodio ya publicado debe convertirse manualmente.
        </p>
        <h2 class="pt-3 pb-1 text-xl font-bold">
          Mis episodios convertidos desaparecieron, ¿por qué?
        </h2>
        Según el estado del almacenamiento, los episodios convertidos se irán eliminando comenzando por los que se convirtieron hace más tiempo. Si un episodio convertido se elimina siempre puede convertirse nuevamente.
        <.link navigate={~p"/status"} class="text-primary">
          El estado del almacenamiento puede consultarse aquí
        </.link>
      </div>
    </article>
    """
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
