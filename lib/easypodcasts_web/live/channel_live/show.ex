defmodule EasypodcastsWeb.ChannelLive.Show do
  use EasypodcastsWeb, :live_view
  import Ecto.Changeset
  alias Phoenix.PubSub
  alias Easypodcasts.Channels.DataProcess
  alias Easypodcasts.Repo

  alias Easypodcasts.Channels

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Easypodcasts.PubSub, "queue_state")
      PubSub.subscribe(Easypodcasts.PubSub, "channel#{id}")
    end

    {:ok, assign(socket, :queue_len, DataProcess.get_queue_len())}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:channel, Channels.get_channel!(id))}
  end

  @impl true
  def handle_event("process_episode", %{"episode_id" => episode_id}, socket) do
    # TODO: Move this from here
    episode = Channels.get_episode!(episode_id)

    socket =
      if episode.status == :new do
        episode
        |> change(%{status: :processing})
        |> Repo.update()

        DataProcess.process_episode(episode_id)

        msg =
          Enum.random([
            "Sit and relax",
            "Go grab a drink",
            "Do some stretching"
          ])

        socket
        # TODO: Don't fetch the channel again, just the episode that changed
        |> update(:channel, fn _ -> Channels.get_channel!(socket.assigns.channel.id) end)
        |> put_flash(:info, "The episode is in queue. #{msg}")
      else
        put_flash(socket, :error, "Sorry. That episode can't be processed right now")
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Channel"

  defp format_date(date) do
    localized = DateTime.shift_zone!(date, "America/Havana")
    "#{localized.year}/#{localized.month}/#{localized.day} #{localized.hour}:#{localized.minute}"
  end

  @impl true
  def handle_info(
        {:episode_processed, %{channel_id: channel_id, episode_title: episode_title}},
        socket
      ) do
    socket =
      socket
      |> put_flash(:success, "The episode '#{episode_title}' was processed successfully")
      |> update(:channel, fn _ -> Channels.get_channel!(channel_id) end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:queue_changed, socket) do
    {:noreply, update(socket, :queue_len, fn _ -> DataProcess.get_queue_len() end)}
  end

  defp format_duration(duration) when is_binary(duration) do
    cond do
      String.contains?(duration, ":") -> duration
      true -> format_duration(String.to_integer(duration))
    end
  end

  defp format_duration(duration) when is_integer(duration) do
    time = Time.new!(0, 0, 0) |> Time.add(duration)
    "#{time.hour}:#{time.minute}:#{time.second}"
  end
end
