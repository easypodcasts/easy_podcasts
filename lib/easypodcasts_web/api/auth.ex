defmodule EasypodcastsWeb.Api.Auth do
  @moduledoc """
  Api authentication using Phoenix.Token
  """
  import Plug.Conn
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, worker_id} <-
           Phoenix.Token.verify(EasypodcastsWeb.Endpoint, "worker auth", token, max_age: :infinity) do
      conn
      |> assign(:current_worker, worker_id)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(EasypodcastsWeb.ErrorView)
        |> Phoenix.Controller.render(:"401")
        |> halt()
    end
  end
end
