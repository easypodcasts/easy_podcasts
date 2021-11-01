defmodule EasypodcastsWeb.EpisodeLiveTest do
  use EasypodcastsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Easypodcasts.ChannelsFixtures

  @create_attrs %{description: "some description", link: "some link", original_audio_url: "some original_audio_url", original_size: 42, processed: true, processed_audio_url: "some processed_audio_url", processed_size: 42, title: "some title"}
  @update_attrs %{description: "some updated description", link: "some updated link", original_audio_url: "some updated original_audio_url", original_size: 43, processed: false, processed_audio_url: "some updated processed_audio_url", processed_size: 43, title: "some updated title"}
  @invalid_attrs %{description: nil, link: nil, original_audio_url: nil, original_size: nil, processed: false, processed_audio_url: nil, processed_size: nil, title: nil}

  defp create_episode(_) do
    episode = episode_fixture()
    %{episode: episode}
  end

  describe "Index" do
    setup [:create_episode]

    test "lists all episodes", %{conn: conn, episode: episode} do
      {:ok, _index_live, html} = live(conn, Routes.episode_index_path(conn, :index))

      assert html =~ "Listing Episodes"
      assert html =~ episode.description
    end

    test "saves new episode", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.episode_index_path(conn, :index))

      assert index_live |> element("a", "New Episode") |> render_click() =~
               "New Episode"

      assert_patch(index_live, Routes.episode_index_path(conn, :new))

      assert index_live
             |> form("#episode-form", episode: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#episode-form", episode: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.episode_index_path(conn, :index))

      assert html =~ "Episode created successfully"
      assert html =~ "some description"
    end

    test "updates episode in listing", %{conn: conn, episode: episode} do
      {:ok, index_live, _html} = live(conn, Routes.episode_index_path(conn, :index))

      assert index_live |> element("#episode-#{episode.id} a", "Edit") |> render_click() =~
               "Edit Episode"

      assert_patch(index_live, Routes.episode_index_path(conn, :edit, episode))

      assert index_live
             |> form("#episode-form", episode: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#episode-form", episode: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.episode_index_path(conn, :index))

      assert html =~ "Episode updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes episode in listing", %{conn: conn, episode: episode} do
      {:ok, index_live, _html} = live(conn, Routes.episode_index_path(conn, :index))

      assert index_live |> element("#episode-#{episode.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#episode-#{episode.id}")
    end
  end

  describe "Show" do
    setup [:create_episode]

    test "displays episode", %{conn: conn, episode: episode} do
      {:ok, _show_live, html} = live(conn, Routes.episode_show_path(conn, :show, episode))

      assert html =~ "Show Episode"
      assert html =~ episode.description
    end

    test "updates episode within modal", %{conn: conn, episode: episode} do
      {:ok, show_live, _html} = live(conn, Routes.episode_show_path(conn, :show, episode))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Episode"

      assert_patch(show_live, Routes.episode_show_path(conn, :edit, episode))

      assert show_live
             |> form("#episode-form", episode: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#episode-form", episode: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.episode_show_path(conn, :show, episode))

      assert html =~ "Episode updated successfully"
      assert html =~ "some updated description"
    end
  end
end
