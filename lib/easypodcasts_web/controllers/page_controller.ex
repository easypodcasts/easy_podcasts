defmodule EasypodcastsWeb.PageController do
  use EasypodcastsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
