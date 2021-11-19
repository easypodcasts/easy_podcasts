defmodule EasypodcastsWeb.ChannelLive.Index do
  use EasypodcastsWeb, :live_view

  alias Easypodcasts.{Channels, ChannelImage}
  alias Easypodcasts.Channels.Channel
  alias Easypodcasts.Helpers.Search
  import Easypodcasts.Helpers
  import EasypodcastsWeb.PaginationComponent

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "New Channel")
    |> assign(:changeset, Channels.change_channel(%Channel{}))
    |> assign(list_channels(params))
  end

  defp apply_action(socket, :index, params) do
    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(list_channels(params))
  end

  @impl true
  def handle_event("save", %{"channel" => channel_params}, socket) do
    case Channels.create_channel(channel_params) do
      {:ok, channel} ->
        Process.send_after(self(), :clear_flash, 5000)

        {:noreply,
         socket
         |> put_flash(:success, "Podcast '#{channel.title}' created successfully")
         |> assign(list_channels(%{"search" => "", page: nil}))
         |> push_patch(to: Routes.channel_index_path(socket, :index))}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, msg} ->
        {:noreply, put_flash(socket, :error, msg)}
    end
  end

  @impl true
  def handle_event("search", %{"search" => ""}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.channel_index_path(
           socket,
           :index,
           Keyword.drop(socket.assigns.params, [:search])
         )
     )}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    socket =
      # We validate here to not overwrite current channels if the search query
      # is invalid
      case Search.validate_search(search) do
        %{valid?: true, changes: %{search_phrase: search_phrase}} ->
          push_patch(socket,
            to:
              Routes.channel_index_path(
                socket,
                :index,
                Keyword.put(socket.assigns.params, :search, search)
              )
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:queue_changed, queue_len}, socket) do
    send_update(EasypodcastsWeb.QueueComponent, id: "queue_state", queue_len: queue_len)
    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp list_channels(params) do
    search = params["search"]

    page =
      if params["page"],
        do: String.to_integer(params["page"]),
        else: 1

    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages,
      params: params
    } = Channels.search_paginate_channels(search, page)

    page = page || 1
    page_range = get_page_range(page, total_pages)

    [
      channels: entries,
      page_number: page_number || 0,
      page_size: page_size || 0,
      total_entries: total_entries || 0,
      total_pages: total_pages || 0,
      page_range: page_range,
      search: search,
      params: params
    ]
  end
end
