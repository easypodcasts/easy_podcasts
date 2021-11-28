defmodule EasypodcastsWeb.ApiController do
  use EasypodcastsWeb, :controller
  alias Easypodcasts.Episodes

  def next(conn, _params) do
    episode = Episodes.next_episode(conn.assigns.current_worker)
    json(conn, episode)
  end

  def converted(conn, %{"id" => episode_id, "audio" => upload = %Plug.Upload{}}) do
    episode_id |> String.to_integer() |> Episodes.converted(upload, conn.assigns.current_worker)
    json(conn, :ok)
  end

  def cancel(conn, %{"id" => episode_id}) do
    episode_id |> String.to_integer() |> Episodes.cancel(conn.assigns.current_worker)
    Episodes.cancel(String.to_integer(episode_id))
    json(conn, :ok)
  end
end
