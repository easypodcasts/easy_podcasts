defmodule EasypodcastsWeb.ChannelController do
  use EasypodcastsWeb, :controller
  alias Easypodcasts.{Channels, Episodes}

  def feed(conn, %{"slug" => slug} = _params) do
    [channel_id | _] = String.split(slug, "-")
    channel = Channels.get_channel_for_feed(channel_id)

    conn
    |> put_resp_content_type("text/xml")
    |> put_layout(false)
    |> render("feed.xml", channel: channel)
  end

  def counter(conn, _) do
    case Plug.Conn.get_req_header(conn, "x-original-uri") do
      [] ->
        send_resp(conn, 404, "Not found")

      [original_uri | _] ->
        Task.start(fn -> count_download(original_uri) end)
        send_resp(conn, :ok, "")
    end
  end

  defp count_download(uri) do
    uri
    |> String.split("/")
    |> Enum.take(-2)
    |> hd
    |> Episodes.inc_episode_downloads()
  end
end
