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
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Home"
      assert html =~ channel.title
    end

    test "saves new channel", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live |> element("#add-podcast") |> render_click() =~
               "Add New Podcast"

      {:ok, _, html} =
        index_live
        |> form("#channel-form", channel: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert html =~ "Elixir Mix"
    end
  end
end
