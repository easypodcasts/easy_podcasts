defmodule Easypodcasts.Helpers.Feed do
  @moduledoc """
  RSS feed helpers
  """
  @feed_parser Path.expand("./priv/bin/feed-parser")
  require Logger

  def get_feed_data(url) do
    url = proxify(url)
    Logger.info("Fetching #{url}")

    with {json_string, 0} <- System.cmd(@feed_parser, ["-feed.url", url]),
         {:ok, feed} <- Jaxon.decode(json_string) do
      Logger.info("Feed for #{url} fetched succesfully")
      {:ok, feed}
    else
      error ->
        Logger.info("Failed to get and parse feed for #{url} with error #{inspect(error)}")
        {:error, "Failed to get and parse feed"}
    end
  end

  defp proxify(url) do
    proxy_url = Application.get_env(:easypodcasts, Easypodcasts)[:proxy_url]
    proxy_token = Application.get_env(:easypodcasts, Easypodcasts)[:proxy_token]
    "#{proxy_url}?bringme=#{url}&token=#{proxy_token}"
  end
end
