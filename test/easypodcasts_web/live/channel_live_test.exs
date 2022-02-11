defmodule EasypodcastsWeb.ChannelLiveTest do
  use EasypodcastsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Easypodcasts.ChannelsFixtures

  @create_attrs %{link: "https://easypodcasts.live/feeds/58-elixir-mix"}

  defp create_channel(_) do
    channel = channel_fixture()
    %{channel: channel}
  end

  describe "Index" do
    setup [:create_channel]

    test "lists all channels", %{conn: conn, channel: channel} do
      {:ok, _index_live, html} = live(conn, Routes.channel_index_path(conn, :index))

      assert html =~ "Home"
      assert html =~ channel.title
    end

    test "saves new channel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.channel_index_path(conn, :index))

      assert index_live |> element("#add-podcast") |> render_click() =~
               "Add New Podcast"

      # assert_patch(index_live, Routes.channel_index_path(conn, :new))

      {:ok, _, html} =
        index_live
        |> form("#channel-form", channel: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.channel_index_path(conn, :index))

      assert html =~ "Elixir Mix"
    end
  end

  # describe "Show" do
  #   setup [:create_channel]

  #   test "displays channel", %{conn: conn, channel: channel} do
  #     {:ok, _show_live, html} = live(conn, Routes.channel_show_path(conn, :show, channel))

  #     assert html =~ "Show Channel"
  #     assert html =~ channel.author
  #   end
  # end
end
