defmodule EasypodcastsWeb.ChannelController do
  use EasypodcastsWeb, :controller
  alias Easypodcasts.Channels

  def feed(conn, %{"slug" => slug} = _params) do
    [channel_id | _] = String.split(slug, "-")
    channel = Channels.get_channel_for_feed!(channel_id)

    conn
    |> put_resp_content_type("text/xml")
    |> put_layout(false)
    |> render("feed.xml", channel: channel)
  end
end
