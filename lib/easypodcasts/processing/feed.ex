defmodule Easypodcasts.Processing.Feed do
  alias ElixirFeedParser.Parsers.ITunesRSS2
  alias ElixirFeedParser.XmlNode

  def get_feed_data(url) do
    with {:ok, %Finch.Response{body: body} = _response} <- request(url),
         {:ok, feed} <- parse_feed(body),
         do: {:ok, feed}
  end

  defp request(url) do
    response = Finch.build(:get, url) |> Finch.request(FinchRequests)

    case response do
      {:ok, %Finch.Response{}} -> response
      {:error, _} -> {:error, "Error while fetching the url"}
    end
  end

  defp parse_feed(xml_string) do
    with {:ok, xml} <- XmlNode.parse_string(xml_string),
         {:ok, ITunesRSS2, xml} <- determine_feed_parser(xml),
         do: {:ok, ITunesRSS2.parse(xml)}
  end

  defp determine_feed_parser(xml) do
    case ElixirFeedParser.determine_feed_parser(xml) do
      {:ok, ITunesRSS2, xml} -> {:ok, ITunesRSS2.parse(xml)}
      _ -> {:error, "The feed is invalid"}
    end
  end
end
