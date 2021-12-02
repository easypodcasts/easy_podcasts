defmodule EasypodcastsWeb.ApiController do
  use EasypodcastsWeb, :controller
  alias Easypodcasts.Episodes

  def next(conn, _params) do
    episode = Episodes.next_episode(conn.assigns.current_worker)
    json(conn, episode)
  end

  def converted(conn, %{"id" => episode_id, "audio" => upload = %Plug.Upload{}}) do
    {status, msg} =
      case episode_id
           |> String.to_integer()
           |> Episodes.converted(upload, conn.assigns.current_worker) do
        :ok -> {:ok, "all good"}
        msg -> {:bad_request, msg}
      end

    conn |> put_status(status) |> json(msg)
  end

  def cancel(conn, %{"id" => episode_id}) do
    {status, msg} =
      case episode_id do
        "" ->
          {:bad_request, "episode id is required"}

        episode_id ->
          episode_id
          |> String.to_integer()
          |> Episodes.cancel(conn.assigns.current_worker)

          {:ok, "episode cancelled"}
      end

    conn |> put_status(status) |> json(msg)
  end
end
