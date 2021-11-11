defmodule Easypodcasts.Processing do
  alias Easypodcasts.Channels
  alias Easypodcasts.Processing.Feed

  def process_all_channels() do
    Channels.list_channels()
    |> Enum.each(fn channel -> Task.start(fn -> process_channel(channel, true) end) end)
  end

  def process_channel(channel, process_new_episodes \\ false) do
    {:ok, new_episodes} =
      with {:ok, feed_data} <- Feed.get_feed_data(channel.link),
           do: save_new_episodes(channel, feed_data)

    if process_new_episodes do
      Enum.each(new_episodes, &Channels.enqueue_episode/1)
    end
  end

  def save_new_episodes(channel, feed_data) do
    episode_audio_urls = Channels.get_episodes_url_from_channel(channel.id)

    new_episodes =
      feed_data.entries
      |> Enum.filter(fn entry -> entry.enclosure.url not in episode_audio_urls end)
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

    {tmp_episode_file, episode_file, processed_audio_url} =
      create_filesytem_directories(
        episode.channel_id,
        episode.id,
        episode.original_audio_url
      )

    with {:ok, :saved_to_file} <- download_file(episode.original_audio_url, tmp_episode_file),
         {_, 0} <- compress_audio(tmp_episode_file, episode_file) do
      cleanup_filesystem([tmp_episode_file])
      new_size = get_file_size(episode_file)

      Channels.update_episode(episode, %{
        status: :done,
        processed_audio_url: processed_audio_url,
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

  defp create_filesytem_directories(channel_id, episode_id, original_audio_url) do
    id_path = Path.join(to_string(channel_id), to_string(episode_id))
    tmp_episode_dir = Path.join([System.tmp_dir!(), "easypodcasts", id_path])
    episode_dir = Path.join("priv/static/podcasts", id_path)

    File.mkdir_p!(tmp_episode_dir)
    File.mkdir_p!(episode_dir)

    episode_file_name = get_filename_from_url(original_audio_url)
    tmp_episode_file = Path.join(tmp_episode_dir, episode_file_name)
    episode_file = "#{Path.join(episode_dir, episode_file_name)}.opus"

    processed_audio_url =
      Path.join(
        id_path,
        "#{episode_file_name}.opus"
      )

    {tmp_episode_file, episode_file, processed_audio_url}
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

  defp get_filename_from_url(url) do
    url
    |> String.split("/")
    |> List.last()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-.]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  defp get_file_size(file) do
    {:ok, %{size: size}} = File.stat(file)
    size
  end
end
