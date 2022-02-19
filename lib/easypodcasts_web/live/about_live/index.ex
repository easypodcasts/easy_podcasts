defmodule EasypodcastsWeb.AboutLive.Index do
  @moduledoc """
  About view
  """
  use EasypodcastsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_modal, false)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
