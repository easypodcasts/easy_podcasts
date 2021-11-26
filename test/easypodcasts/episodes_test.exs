defmodule Easypodcasts.EpisodesTest do
  use Easypodcasts.DataCase

  alias Easypodcasts.Episodes

  describe "episodes" do
    alias Easypodcasts.Episodes.Episode

    import Easypodcasts.EpisodesFixtures

    @invalid_attrs %{name: nil}

    test "list_episodes/0 returns all episodes" do
      episode = episode_fixture()
      assert Episodes.list_episodes() == [episode]
    end

    test "get_episode!/1 returns the episode with given id" do
      episode = episode_fixture()
      assert Episodes.get_episode!(episode.id) == episode
    end

    test "create_episode/1 with valid data creates a episode" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Episode{} = episode} = Episodes.create_episode(valid_attrs)
      assert episode.name == "some name"
    end

    test "create_episode/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Episodes.create_episode(@invalid_attrs)
    end

    test "update_episode/2 with valid data updates the episode" do
      episode = episode_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Episode{} = episode} = Episodes.update_episode(episode, update_attrs)
      assert episode.name == "some updated name"
    end

    test "update_episode/2 with invalid data returns error changeset" do
      episode = episode_fixture()
      assert {:error, %Ecto.Changeset{}} = Episodes.update_episode(episode, @invalid_attrs)
      assert episode == Episodes.get_episode!(episode.id)
    end

    test "delete_episode/1 deletes the episode" do
      episode = episode_fixture()
      assert {:ok, %Episode{}} = Episodes.delete_episode(episode)
      assert_raise Ecto.NoResultsError, fn -> Episodes.get_episode!(episode.id) end
    end

    test "change_episode/1 returns a episode changeset" do
      episode = episode_fixture()
      assert %Ecto.Changeset{} = Episodes.change_episode(episode)
    end
  end
end
