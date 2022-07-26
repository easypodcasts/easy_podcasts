defmodule Easypodcasts.Helpers.Feed do
  @moduledoc """
  RSS feed helpers
  """
  @feed_parser Path.expand("./priv/bin/feed-parser")
  require Logger

  def get_feed_data(url) do
    with {json_string, 0} <- System.cmd(@feed_parser, ["-feed.url", url]),
         {:ok, feed} <- Jaxon.decode(json_string) do
      # Logger.info("Feed for #{url} fetched succesfully")
      {:ok, feed}
    else
      error ->
        # Logger.info("Failed to get and parse feed for #{url} with error #{inspect error}")
        {:error, "Failed to get and parse feed"}
    end
  end
end
