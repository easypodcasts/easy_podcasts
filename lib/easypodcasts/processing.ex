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
      Enum.each(new_episodes, &Channels.enqueue_episode/1)
    end
  end

  def save_new_episodes(channel, feed_data) do
    # episode_audio_urls = Channels.get_episodes_url_from_channel(channel.id)
    episode_audio_urls = Channels.get_episodes_url()
    # Logger.info("Channel #{channel.title} has #{length(episode_audio_urls)} episodes")
    Logger.info("All episodes #{length(episode_audio_urls)}")

    new_episodes =
      feed_data.entries
      |> then(fn entries ->
        Logger.info("The feed for the channel #{channel.title} has #{length(entries)} entries")
        entries
      end)
      |> Enum.filter(fn entry -> entry.enclosure.url not in episode_audio_urls end)
      |> then(fn filtered_entries ->
        Logger.info(
          "The feed for the channel #{channel.title} has #{length(filtered_entries)} new entries"
        )

        filtered_entries
      end)
      |> Enum.map(fn entry ->
        # TODO validate this stuff
        %{
          description: entry.description,
          title: entry.title,
          link: entry.url,
          original_audio_url: entry.enclosure.url,
          original_size: String.to_integer(entry.enclosure.length),
          channel_id: channel.id,
          publication_date: DateTime.shift_zone!(entry."rss2:pubDate", "Etc/UTC"),
          feed_data: entry
        }
      end)

    {_, episodes} = Channels.create_episodes(new_episodes)
    {:ok, episodes}
  end

  def process_episode_file(episode) do
    {:ok, episode} = Channels.update_episode(episode, %{status: :processing})

    {tmp_episode_file, episode_file} =
      create_filesytem_directories(
        episode.channel_id,
        episode.id
      )

    with {:ok, :saved_to_file} <- download_file(episode.original_audio_url, tmp_episode_file),
         {_, 0} <- compress_audio(tmp_episode_file, episode_file) do
      cleanup_filesystem([tmp_episode_file])
      new_size = get_file_size(episode_file)

      Channels.update_episode(episode, %{
        status: :done,
        processed_size: new_size
      })
    else
      _error ->
        cleanup_filesystem([tmp_episode_file, episode_file])

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
    tmp_episode_dir =
      Path.join([System.tmp_dir!(), "easypodcasts", to_string(channel_id), to_string(episode_id)])

    episode_dir = Path.join(["uploads", to_string(channel_id), "episodes", to_string(episode_id)])

    File.mkdir_p!(tmp_episode_dir)
    File.mkdir_p!(episode_dir)

    episode_file_name = "episode.opus"
    tmp_episode_file = Path.join(tmp_episode_dir, episode_file_name)
    episode_file = Path.join(episode_dir, episode_file_name)

    {tmp_episode_file, episode_file}
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

  defp cleanup_filesystem(files, directories \\ []) do
    # The order of the directories is important
    Enum.each(files, &File.rm/1)
    Enum.each(directories, &File.rmdir/1)
  end

  defp get_file_size(file) do
    {:ok, %{size: size}} = File.stat(file)
    size
  end
end
