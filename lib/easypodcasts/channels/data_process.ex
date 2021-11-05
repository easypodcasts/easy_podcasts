defmodule Easypodcasts.Channels.DataProcess do
  use GenServer
  import Ecto.Query
  import Ecto.Changeset
  alias Easypodcasts.Repo
  alias Easypodcasts.Channels.Episode
  alias ElixirFeedParser.Parsers.ITunesRSS2
  alias ElixirFeedParser.XmlNode
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(
      __MODULE__,
      %{},
      name: __MODULE__
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:process, episode_id}, state) do
    queue_changed()
    episode = Easypodcasts.Channels.get_episode!(episode_id)

    if episode.status == :processing do
      process_episode_file(episode)
    end

    {:noreply, state}
  end

  def process_episode(episode) do
    queue_changed()

    episode
    |> change(%{status: :processing})
    |> Repo.update()

    GenServer.cast(__MODULE__, {:process, episode.id})
  end

  def update_all_channels(process_new_episodes \\ false) do
    Easypodcasts.Channels.list_channels()
    |> Enum.each(fn channel -> update_channel(channel, process_new_episodes) end)
  end

  def update_channel(channel, process_new_episodes \\ false) do
    case get_channel_data(channel.link) do
      {:ok, channel_data} ->
        Task.start(fn -> process_channel_data(channel, channel_data, process_new_episodes) end)

      _ ->
        nil
    end
  end

  def get_channel_data(url) do
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

  def process_channel_data(channel, new_data, process_episodes \\ false) do
    episode_audio_urls =
      Repo.all(
        from e in Episode, where: e.channel_id == ^channel.id, select: e.original_audio_url
      )

    new_episodes =
      new_data.entries
      |> Enum.filter(fn entry -> entry.enclosure.url not in episode_audio_urls end)
      |> Enum.map(fn entry ->
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

    {_, episodes} = Repo.insert_all(Episode, new_episodes, returning: true)

    if process_episodes do
      episodes |> Enum.each(fn episode -> process_episode(episode.id) end)
    end
  end

  def process_episode_file(episode) do
    tmp_dir = System.tmp_dir!()

    tmp_channel_dir =
      Path.join([tmp_dir, "easypodcasts", to_string(episode.channel_id), to_string(episode.id)])

    channel_dir =
      Path.join(["priv/static/podcasts", to_string(episode.channel_id), to_string(episode.id)])

    File.mkdir_p!(tmp_channel_dir)
    File.mkdir_p!(channel_dir)

    episode_file_name =
      episode.original_audio_url
      |> String.split("/")
      |> List.last()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\s-.]/, "")
      |> String.replace(~r/(\s|-)+/, "-")

    tmp_episode_file = Path.join(tmp_channel_dir, episode_file_name)
    episode_file = "#{Path.join(channel_dir, episode_file_name)}.opus"

    processed_audio_url =
      Path.join([to_string(episode.channel_id), to_string(episode.id), "#{episode_file_name}.opus"])

    {:ok, :saved_to_file} =
      :httpc.request(:get, {String.to_charlist(episode.original_audio_url), []}, [],
        stream: String.to_charlist(tmp_episode_file)
      )

    {_, 0} =
      System.cmd("ffmpeg", [
        "-i",
        tmp_episode_file,
        "-c:a",
        "libopus",
        "-b:a",
        "32k",
        "-vbr",
        "on",
        "-compression_level",
        "10",
        "-frame_duration",
        "60",
        "-application",
        "voip",
        episode_file
      ])

    File.rm!(tmp_episode_file)

    {:ok, %{size: size}} = File.stat(episode_file)

    episode
    |> change(%{status: :done, processed_audio_url: processed_audio_url, processed_size: size})
    |> Repo.update()

    episode_processed(episode.channel_id, episode.title)
  end

  defp queue_changed do
    PubSub.broadcast(Easypodcasts.PubSub, "queue_state", :queue_changed)
  end

  def get_queue_len do
    {:message_queue_len, len} = Process.info(Process.whereis(__MODULE__), :message_queue_len)
    len
  end

  defp episode_processed(channel_id, episode_title) do
    PubSub.broadcast(
      Easypodcasts.PubSub,
      "channel#{channel_id}",
      {:episode_processed, %{channel_id: channel_id, episode_title: episode_title}}
    )
  end
end
