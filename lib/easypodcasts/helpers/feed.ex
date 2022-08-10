defmodule Easypodcasts.Helpers.Feed do
  @moduledoc """
  RSS feed helpers
  """
  @feed_parser Path.expand("./priv/bin/feed-parser")
  require Logger

  def get_feed_data(original_url, is_retry \\ false) do
    url = if is_retry, do: original_url, else: proxify(original_url)

    Logger.info("Fetching #{url}")

    with {json_string, 0} <- System.cmd(@feed_parser, ["-feed.url", url]),
         {:ok, feed} <- Jaxon.decode(json_string) do
      Logger.info("Feed for #{url} fetched succesfully")
      {:ok, feed}
    else
      {"Failed to detect feed type\n", 1} ->
        if !is_retry do
          get_feed_data(original_url, true)
        else
          proxify(original_url)

          Logger.info(
            "Failed to get and parse feed for #{original_url} with error #{inspect({"Failed to detect feed type\n", 1})}"
          )

          {:error, "Failed to get and parse feed"}
        end

      error ->
        Logger.info("Failed to get and parse feed for #{url} with error #{inspect(error)}")
        {:error, "Failed to get and parse feed"}
    end
  end

  def proxify(url) do
    proxy_url = Application.get_env(:easypodcasts, Easypodcasts)[:proxy_url]
    proxy_token = Application.get_env(:easypodcasts, Easypodcasts)[:proxy_token]
    "#{proxy_url}/?token=#{proxy_token}&bringme=#{url}"
  end
end
