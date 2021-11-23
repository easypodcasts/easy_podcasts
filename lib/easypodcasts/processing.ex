defmodule Easypodcasts.Processing do
  alias Easypodcasts.Channels
  alias Easypodcasts.Processing.Feed
  require Logger

  def process_all_channels() do
    Logger.info("Processing all channels")

    Channels.list_channels()
    |> Enum.each(&process_channel(&1, true))
  end

  def process_channel(channel, process_new_episodes \\ false) do
    Logger.info("Processing channel #{channel.title}")

    with {:ok, feed_data} <- Feed.get_feed_data(channel.link),
         {_, new_episodes = [_ | _]} <- save_new_episodes(channel, feed_data) do
      Logger.info("Channel #{channel.title} has #{length(new_episodes)} new episodes")

      if process_new_episodes do
        Logger.info("Processing audio from new episodes of #{channel.title}")
        Enum.each(new_episodes, &Channels.enqueue_episode(&1.id))
      end

      {:ok, new_episodes}
    else
      _ ->
        {:error, channel,
         "We can't process that podcast right now. Please create an issue with the feed url."}
    end
  end

  def save_new_episodes(channel, feed_data) do
    # episode_audio_urls = Channels.get_episodes_url_from_channel(channel.id)
    episode_audio_urls = Channels.get_episodes_url()

    (feed_data["items"] || [])
    |> Stream.filter(&(&1["enclosures"] && hd(&1["enclosures"])["url"] not in episode_audio_urls))
    |> Stream.map(&episode_item_to_map(&1, channel.id))
    |> Enum.to_list()
    |> Channels.create_episodes()
  end

  defp episode_item_to_map(item, channel_id) do
    publication_date =
      with {:ok, parsed_datetime} <- Timex.parse(item["publishedParsed"], "{ISO:Extended}"),
           {:ok, shifted_datetime} <- DateTime.shift_zone(parsed_datetime, "Etc/UTC") do
        shifted_datetime
      else
        _ -> DateTime.utc_now()
      end

    %{
      description: item["description"],
      title: item["title"],
      link: item["link"],
      original_audio_url: item["enclosures"] && hd(item["enclosures"])["url"],
      original_size:
        item["enclosures"] &&
          (hd(item["enclosures"])["length"] || "0") |> String.trim() |> String.to_integer(),
      channel_id: channel_id,
      publication_date: publication_date,
      feed_data: item
    }
  end

  def process_episode_file(episode) do
    {:ok, episode} = Channels.update_episode(episode, %{status: :processing})

    episode_file =
      create_filesytem_directories(
        episode.channel_id,
        episode.id
      )

    case compress_audio(episode.original_audio_url, episode_file) do
      {_, 0} ->
        new_size = get_file_size(episode_file)

        Channels.update_episode(episode, %{
          status: :done,
          processed_size: new_size
        })

      _error ->
        {:ok, episode} =
          Channels.update_episode(episode, %{
            status: :new
          })

        {:error, episode}
    end
  end

  def download_file(url, dest) do
    :httpc.request(:get, {String.to_charlist(url), []}, [], stream: String.to_charlist(dest))
  end

  defp create_filesytem_directories(channel_id, episode_id) do
    episode_dir = Path.join(["uploads", to_string(channel_id), "episodes", to_string(episode_id)])
    File.mkdir_p!(episode_dir)
    episode_file = Path.join(episode_dir, "episode.opus")
    episode_file
  end

  defp compress_audio(orig, dest) do
    System.cmd("ffmpeg", [
      "-y",
      "-i",
      orig,
      "-ac",
      "1",
      "-c:a",
      "libopus",
      "-b:a",
      "24k",
      "-vbr",
      "on",
      "-compression_level",
      "10",
      "-frame_duration",
      "60",
      "-application",
      "voip",
      dest
    ])
  end

  defp get_file_size(file) do
    {:ok, %{size: size}} = File.stat(file)
    size
  end
end
