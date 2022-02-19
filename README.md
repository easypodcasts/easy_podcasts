# Easypodcasts

Easy Podcasts es una solución comunitaria para la descarga de podcasts que tiene como objetivo ayudar a disminuir el consumo de datos: el servicio está alojado en .cu y los archivos de audio son comprimidos.

Hosteado en: https://easypodcasts.live

## Desarrollo

### Requisitos:

 * Elixir 1.12
 * PostgreSQL
 * ffmpeg

Para iniciar el servidor de desarrollo

  * Instalar dependencias con `mix deps.get`
  * Crear y migrar la base de datos con `mix ecto.setup`
  * Instalar las dependencias de node con `cd assets && npm i`
  * Iniciar el servidor de Phoenix con `mix phx.server` o dentro de IEx con `iex -S mix phx.server`

Ahora puedes visitar [`localhost:4000`](http://localhost:4000) en tu navegador.
