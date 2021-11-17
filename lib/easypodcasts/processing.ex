defmodule Easypodcasts.Processing do
  alias Easypodcasts.Channels
  alias Easypodcasts.Processing.Feed
  require Logger

  def process_all_channels() do
    Logger.info("Processing all channels")

    Channels.list_channels()
    |> Enum.each(fn channel -> process_channel(channel, true) end)
  end

  def process_channel(channel, process_new_episodes \\ false) do
    Logger.info("Processing channel #{channel.title}")

    {:ok, new_episodes} =
      with {:ok, feed_data} <- Feed.get_feed_data(channel.link),
           do: save_new_episodes(channel, feed_data)

    Logger.info("Channel #{channel.title} has #{length(new_episodes)} new episodes")

    if process_new_episodes do
      Logger.info("Processing audio from new episodes of #{channel.title}")
      Enum.each(new_episodes, fn episode -> Channels.enqueue_episode(episode.id) end)
    end
  end

  def save_new_episodes(channel, feed_data) do
    # episode_audio_urls = Channels.get_episodes_url_from_channel(channel.id)
    episode_audio_urls = Channels.get_episodes_url()
    # Logger.info("Channel #{channel.title} has #{length(episode_audio_urls)} episodes")
    Logger.info("All episodes #{length(episode_audio_urls)}")

    new_episodes =
      feed_data["items"]
      |> then(fn items ->
        Logger.info("The feed for the channel #{channel.title} has #{length(items)} items")
        items
      end)
      |> Enum.filter(fn item -> hd(item["enclosures"])["url"] not in episode_audio_urls end)
      |> then(fn filtered_items ->
        Logger.info(
          "The feed for the channel #{channel.title} has #{length(filtered_items)} new items"
        )

        filtered_items
      end)
      |> Enum.map(fn item ->
        # TODO validate this stuff
        %{
          description: item["description"],
          title: item["title"],
          link: item["link"],
          original_audio_url: hd(item["enclosures"])["url"],
          original_size: String.to_integer(hd(item["enclosures"])["length"]),
          channel_id: channel.id,
          publication_date:
            DateTime.shift_zone!(
              Timex.parse!(item["publishedParsed"], "{ISO:Extended}"),
              "Etc/UTC"
            ),
          feed_data: item
        }
      end)

    {_, episodes} = Channels.create_episodes(new_episodes)
    {:ok, episodes}
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
