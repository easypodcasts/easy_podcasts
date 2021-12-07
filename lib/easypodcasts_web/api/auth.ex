defmodule EasypodcastsWeb.Api.Auth do
  @moduledoc """
  Api authentication using Phoenix.Token
  """
  import Plug.Conn
  require Logger
  alias Easypodcasts.Workers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, worker_id} <-
           Phoenix.Token.verify(EasypodcastsWeb.Endpoint, "worker auth", token, max_age: :infinity),
         true <- Workers.is_active(worker_id) do
      assign(conn, :current_worker, worker_id)
    else
      _invalid ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(EasypodcastsWeb.ErrorView)
        |> Phoenix.Controller.render(:"401")
        |> halt()
    end
  end
end
