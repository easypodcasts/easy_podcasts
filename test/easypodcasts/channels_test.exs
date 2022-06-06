defmodule Easypodcasts.ChannelsTest do
  use Easypodcasts.DataCase

  alias Easypodcasts.Channels

  describe "denylist" do
    alias Easypodcasts.Channels.Denylist

    import Easypodcasts.ChannelsFixtures

    @invalid_attrs %{link: nil, title: nil}

    test "list_denylist/0 returns all denylist" do
      denylist = denylist_fixture()
      assert Channels.list_denylist() == [denylist]
    end

    test "get_denylist!/1 returns the denylist with given id" do
      denylist = denylist_fixture()
      assert Channels.get_denylist!(denylist.id) == denylist
    end

    test "create_denylist/1 with valid data creates a denylist" do
      valid_attrs = %{link: "some link", title: "some title"}

      assert {:ok, %Denylist{} = denylist} = Channels.create_denylist(valid_attrs)
      assert denylist.link == "some link"
      assert denylist.title == "some title"
    end

    test "create_denylist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_denylist(@invalid_attrs)
    end

    test "update_denylist/2 with valid data updates the denylist" do
      denylist = denylist_fixture()
      update_attrs = %{link: "some updated link", title: "some updated title"}

      assert {:ok, %Denylist{} = denylist} = Channels.update_denylist(denylist, update_attrs)
      assert denylist.link == "some updated link"
      assert denylist.title == "some updated title"
    end

    test "update_denylist/2 with invalid data returns error changeset" do
      denylist = denylist_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_denylist(denylist, @invalid_attrs)
      assert denylist == Channels.get_denylist!(denylist.id)
    end

    test "delete_denylist/1 deletes the denylist" do
      denylist = denylist_fixture()
      assert {:ok, %Denylist{}} = Channels.delete_denylist(denylist)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_denylist!(denylist.id) end
    end

    test "change_denylist/1 returns a denylist changeset" do
      denylist = denylist_fixture()
      assert %Ecto.Changeset{} = Channels.change_denylist(denylist)
    end
  end
end
