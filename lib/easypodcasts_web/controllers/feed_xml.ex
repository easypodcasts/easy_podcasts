defmodule EasypodcastsWeb.FeedXML do
  use EasypodcastsWeb, :html

  embed_templates "feed_xml/*", ext: ".xml"

  defp clear_ampersand(nil), do: ""
  defp clear_ampersand(string), do: String.replace(string, "&", "&amp;")
end
