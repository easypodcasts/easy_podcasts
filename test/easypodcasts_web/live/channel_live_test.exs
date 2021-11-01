defmodule EasypodcastsWeb.ChannelLiveTest do
  use EasypodcastsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Easypodcasts.ChannelsFixtures

  @create_attrs %{author: "some author", description: "some description", image_url: "some image_url", link: "some link", title: "some title"}
  @update_attrs %{author: "some updated author", description: "some updated description", image_url: "some updated image_url", link: "some updated link", title: "some updated title"}
  @invalid_attrs %{author: nil, description: nil, image_url: nil, link: nil, title: nil}

  defp create_channel(_) do
    channel = channel_fixture()
    %{channel: channel}
  end

  describe "Index" do
    setup [:create_channel]

    test "lists all channels", %{conn: conn, channel: channel} do
      {:ok, _index_live, html} = live(conn, Routes.channel_index_path(conn, :index))

      assert html =~ "Listing Channels"
      assert html =~ channel.author
    end

    test "saves new channel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.channel_index_path(conn, :index))

      assert index_live |> element("a", "New Channel") |> render_click() =~
               "New Channel"

      assert_patch(index_live, Routes.channel_index_path(conn, :new))

      assert index_live
             |> form("#channel-form", channel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#channel-form", channel: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.channel_index_path(conn, :index))

      assert html =~ "Channel created successfully"
      assert html =~ "some author"
    end

    test "updates channel in listing", %{conn: conn, channel: channel} do
      {:ok, index_live, _html} = live(conn, Routes.channel_index_path(conn, :index))

      assert index_live |> element("#channel-#{channel.id} a", "Edit") |> render_click() =~
               "Edit Channel"

      assert_patch(index_live, Routes.channel_index_path(conn, :edit, channel))

      assert index_live
             |> form("#channel-form", channel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#channel-form", channel: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.channel_index_path(conn, :index))

      assert html =~ "Channel updated successfully"
      assert html =~ "some updated author"
    end

    test "deletes channel in listing", %{conn: conn, channel: channel} do
      {:ok, index_live, _html} = live(conn, Routes.channel_index_path(conn, :index))

      assert index_live |> element("#channel-#{channel.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#channel-#{channel.id}")
    end
  end

  describe "Show" do
    setup [:create_channel]

    test "displays channel", %{conn: conn, channel: channel} do
      {:ok, _show_live, html} = live(conn, Routes.channel_show_path(conn, :show, channel))

      assert html =~ "Show Channel"
      assert html =~ channel.author
    end

    test "updates channel within modal", %{conn: conn, channel: channel} do
      {:ok, show_live, _html} = live(conn, Routes.channel_show_path(conn, :show, channel))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Channel"

      assert_patch(show_live, Routes.channel_show_path(conn, :edit, channel))

      assert show_live
             |> form("#channel-form", channel: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#channel-form", channel: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.channel_show_path(conn, :show, channel))

      assert html =~ "Channel updated successfully"
      assert html =~ "some updated author"
    end
  end
end
