defmodule EasypodcastsWeb.AboutLive.Index do
  @moduledoc """
  About view
  """
  use EasypodcastsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_modal, false)}
  end

  @impl true
  def handle_event("show_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end

  def handle_event("hide_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  @impl true
  def handle_info({:queue_length_changed, queue_length}, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_length: queue_length)
    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
