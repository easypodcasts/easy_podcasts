defmodule Easypodcasts.ChannelsTest do
  use Easypodcasts.DataCase

  alias Easypodcasts.Channels

  describe "channels" do
    alias Easypodcasts.Channels.Channel

    import Easypodcasts.ChannelsFixtures

    @invalid_attrs %{author: nil, description: nil, image_url: nil, link: nil, title: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Channels.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Channels.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{author: "some author", description: "some description", image_url: "some image_url", link: "some link", title: "some title"}

      assert {:ok, %Channel{} = channel} = Channels.create_channel(valid_attrs)
      assert channel.author == "some author"
      assert channel.description == "some description"
      assert channel.image_url == "some image_url"
      assert channel.link == "some link"
      assert channel.title == "some title"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      update_attrs = %{author: "some updated author", description: "some updated description", image_url: "some updated image_url", link: "some updated link", title: "some updated title"}

      assert {:ok, %Channel{} = channel} = Channels.update_channel(channel, update_attrs)
      assert channel.author == "some updated author"
      assert channel.description == "some updated description"
      assert channel.image_url == "some updated image_url"
      assert channel.link == "some updated link"
      assert channel.title == "some updated title"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_channel(channel, @invalid_attrs)
      assert channel == Channels.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Channels.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Channels.change_channel(channel)
    end
  end

  describe "episodes" do
    alias Easypodcasts.Channels.Episode

    import Easypodcasts.ChannelsFixtures

    @invalid_attrs %{description: nil, link: nil, original_audio_url: nil, original_size: nil, processed: nil, processed_audio_url: nil, processed_size: nil, title: nil}

    test "list_episodes/0 returns all episodes" do
      episode = episode_fixture()
      assert Channels.list_episodes() == [episode]
    end

    test "get_episode!/1 returns the episode with given id" do
      episode = episode_fixture()
      assert Channels.get_episode!(episode.id) == episode
    end

    test "create_episode/1 with valid data creates a episode" do
      valid_attrs = %{description: "some description", link: "some link", original_audio_url: "some original_audio_url", original_size: 42, processed: true, processed_audio_url: "some processed_audio_url", processed_size: 42, title: "some title"}

      assert {:ok, %Episode{} = episode} = Channels.create_episode(valid_attrs)
      assert episode.description == "some description"
      assert episode.link == "some link"
      assert episode.original_audio_url == "some original_audio_url"
      assert episode.original_size == 42
      assert episode.processed == true
      assert episode.processed_audio_url == "some processed_audio_url"
      assert episode.processed_size == 42
      assert episode.title == "some title"
    end

    test "create_episode/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_episode(@invalid_attrs)
    end

    test "update_episode/2 with valid data updates the episode" do
      episode = episode_fixture()
      update_attrs = %{description: "some updated description", link: "some updated link", original_audio_url: "some updated original_audio_url", original_size: 43, processed: false, processed_audio_url: "some updated processed_audio_url", processed_size: 43, title: "some updated title"}

      assert {:ok, %Episode{} = episode} = Channels.update_episode(episode, update_attrs)
      assert episode.description == "some updated description"
      assert episode.link == "some updated link"
      assert episode.original_audio_url == "some updated original_audio_url"
      assert episode.original_size == 43
      assert episode.processed == false
      assert episode.processed_audio_url == "some updated processed_audio_url"
      assert episode.processed_size == 43
      assert episode.title == "some updated title"
    end

    test "update_episode/2 with invalid data returns error changeset" do
      episode = episode_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_episode(episode, @invalid_attrs)
      assert episode == Channels.get_episode!(episode.id)
    end

    test "delete_episode/1 deletes the episode" do
      episode = episode_fixture()
      assert {:ok, %Episode{}} = Channels.delete_episode(episode)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_episode!(episode.id) end
    end

    test "change_episode/1 returns a episode changeset" do
      episode = episode_fixture()
      assert %Ecto.Changeset{} = Channels.change_episode(episode)
    end
  end
end
