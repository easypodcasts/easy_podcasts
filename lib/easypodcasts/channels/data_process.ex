defmodule Easypodcasts.Channels.DataProcess do
  use GenServer
  import Ecto.Query
  import Ecto.Changeset
  alias Easypodcasts.Repo
  alias Easypodcasts.Channels.Episode

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
    episode = Easypodcasts.Channels.get_episode!(episode_id)

    if not episode.processed do
      process_episode_file(episode)
    end

    {:noreply, state}
  end

  def process_episode(episode_id) do
    GenServer.cast(__MODULE__, {:process, episode_id})
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
    case :httpc.request(url) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        case ElixirFeedParser.parse(List.to_string(body)) do
          {:ok, feed} -> {:ok, feed}
          {:error, _} -> {:error, "The feed is invalid"}
        end

      {:ok, {{'HTTP/1.1', _, _}, _headers, _body}} ->
        {:error, "Error while fetching the url"}

      {:error, _} ->
        {:error, "Error while fetching the url"}
    end
  end

  def process_channel_data(channel, new_data, process_episodes \\ false) do
    episode_links =
      Repo.all(from e in Episode, where: e.channel_id == ^channel.id, select: e.link)

    new_episodes =
      new_data.entries
      |> Enum.filter(fn entry -> entry.url not in episode_links end)
      |> Enum.map(fn entry ->
        %{
          description: entry.description,
          title: entry.title,
          link: entry.url,
          original_audio_url: entry.enclosure.url,
          channel_id: channel.id
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

    channel_dir = Path.join(["priv/static/podcasts", to_string(episode.channel_id), to_string(episode.id)])

    File.mkdir_p!(tmp_channel_dir)
    File.mkdir_p!(channel_dir)

    episode_file_name = episode.original_audio_url |> String.split("/") |> List.last()
    base_file_name = episode_file_name |> String.split(".") |> hd
    tmp_episode_file = Path.join(tmp_channel_dir, episode_file_name)
    episode_file = "#{Path.join(channel_dir, base_file_name)}.opus"
    processed_audio_url = Path.join([to_string(episode.channel_id), to_string(episode.id), "#{base_file_name}.opus"])

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

    episode |> change(%{processed: true, processed_audio_url: processed_audio_url}) |> Repo.update()
  end
end
