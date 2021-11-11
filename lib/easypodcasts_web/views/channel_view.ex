defmodule EasypodcastsWeb.ChannelView do
  use EasypodcastsWeb, :view
  alias Easypodcasts.EpisodeAudio
  require EEx

  EEx.function_from_file(:def, :feed, "lib/easypodcasts_web/templates/channel/feed.xml.eex", [
    :assigns
  ])

  def render("feed.xml", %{channel: channel}) do
    feed(channel)
  end
end
