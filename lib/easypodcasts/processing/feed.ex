defmodule Easypodcasts.Processing.Feed do
  @feed_parser Path.expand("./priv/bin/feed-parser")

  def get_feed_data(url) do
    with {json_string, 0} <- System.cmd(@feed_parser, ["-feed.url", url]),
         {:ok, feed} <- Jaxon.decode(json_string) do
      {:ok, feed}
    else
      _ -> {:error, "Failed to get and parse feed"}
    end
  end
end
