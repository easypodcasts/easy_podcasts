defmodule EasypodcastsWeb.ApiController do
  use EasypodcastsWeb, :controller
  alias Easypodcasts.Processing.WorkerManager

  def next(conn, _params) do
    json(conn, WorkerManager.next_episode)
  end

  def converted(conn, %{"id" => episode_id, "audio" => upload = %Plug.Upload{}}) do
    dest = "priv/tmp/#{episode_id}"
    File.cp!(upload.path, dest)
    WorkerManager.save_converted_episode(episode_id, dest, conn.assigns.current_worker)
    json(conn, :ok)
  end
end
