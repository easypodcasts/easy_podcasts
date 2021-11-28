defmodule Easypodcasts.Scheduler do
  use GenServer
  require Logger
  alias Easypodcasts.{Channels, Episodes}

  # @drive_id = '/home/cloud/podcasts-storage'

  @name __MODULE__

  def start_link(_opts) do
    Logger.info("#{@name} starting")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_feed_update()
    schedule_disk_maintenance()

    {:ok, state}
  end

  def handle_info(:feed_update, state) do
    Logger.info("#{@name} Scheduled Task: Updating all feeds")
    Channels.process_all_channels()
    schedule_feed_update()
    {:noreply, state}
  end

  def handle_info(:disk_maintenance, state) do
    Logger.info("#{@name} Scheduled Task: Disk Maintenance")
    do_disk_maintenance()
    schedule_disk_maintenance()
    {:noreply, state}
  end

  defp schedule_feed_update() do
    if Mix.env() == :prod do
      Process.send_after(self(), :feed_update, :timer.hours(2))
    end
  end

  defp schedule_disk_maintenance() do
    if Mix.env() == :prod do
      Process.send_after(self(), :disk_maintenance, :timer.hours(1))
    end
  end

  def do_disk_maintenance() do
    {_id, _capacity, percent} =
      :disksup.get_disk_data()
      |> Enum.filter(fn {disk_id, _size, _percent} ->
        disk_id == '/home/cloud/podcasts-storage'
      end)
      |> hd

    Logger.info("Scheduled Task: Disk Maintenance: Disk is #{percent} full")

    cond do
      percent > 95 -> remove_episode_older_than(:day)
      percent > 90 -> remove_episode_older_than(:week)
      percent > 85 -> remove_episode_older_than(:month)
      percent <= 85 -> nil
    end
  end

  defp remove_episode_older_than(:month) do
    Logger.info("Scheduled Task: Disk Maintenance: Removing episodes older than a month")
    date = DateTime.now!("America/Havana") |> DateTime.add(-30 * 24 * 3600, :second)
    Episodes.list_episodes_updated_before(date) |> delete_audio_for |> reset_info
  end

  defp remove_episode_older_than(:week) do
    Logger.info("Scheduled Task: Disk Maintenance: Removing episodes older than a week")
    date = DateTime.now!("America/Havana") |> DateTime.add(-7 * 24 * 3600, :second)
    Episodes.list_episodes_updated_before(date) |> delete_audio_for |> reset_info
  end

  defp remove_episode_older_than(:day) do
    Logger.info("Scheduled Task: Disk Maintenance: Removing episodes older than a day")
    date = DateTime.now!("America/Havana") |> DateTime.add(-1 * 24 * 3600, :second)
    Episodes.list_episodes_updated_before(date) |> delete_audio_for |> reset_info
  end

  def delete_audio_for(episodes) do
    episodes
    |> Easypodcasts.Repo.all()
    |> tap(
      &Logger.info(
        "#{@name} Scheduled Task: Disk Maintenance: Removing audio for #{length(&1)} episodes"
      )
    )
    |> Enum.each(&File.rm("uploads/#{&1.channel_id}/episodes/#{&1.id}/episode.opus"))

    episodes
  end

  def reset_info(episodes) do
    episodes
    |> tap(
      &Logger.info(
        "#{@name} Scheduled Task: Disk Maintenance: Reset info for #{length(Easypodcasts.Repo.all(&1))} episodes"
      )
    )
    |> Easypodcasts.Repo.update_all(
      set: [status: :new, processed_audio_url: nil, processed_size: nil]
    )
  end
end
