defmodule EasypodcastsWeb.PaginationComponent do
  @moduledoc """
  Component to generate the pagination element
  """
  use Phoenix.Component
  use EasypodcastsWeb, :verified_routes
  import EasypodcastsWeb.Gettext

  def pagination(assigns) do
    # TODO figure out how to use live_patch here but scrolling to the top
    # after changing page
    ~H"""
    <nav class="flex justify-center mt-5 mb-5 w-full text-lg">
      <%= if @page_number != 1 do %>
        <.link
          patch={get_route(@channel, @search, @page_number - 1)}
          class="block py-2 px-3 mr-1 ml-0 leading-tight rounded-l-lg hover:bg-primary hover:text-primary-content"
        >
          <span class="sr-only">
            <%= gettext("Previous") %>
          </span>
          <svg class="w-6 h-6 text-primary-dark" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path
              fill-rule="evenodd"
              d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
              clip-rule="evenodd"
            >
            </path>
          </svg>
        </.link>
      <% end %>

      <%= for idx <- Enum.to_list(@page_range) do %>
        <%= if @page_number == idx do %>
          <.link
            patch={get_route(@channel, @search, idx)}
            class="py-2 px-3 mr-1 text-xl leading-tight rounded pointer-events-none bg-primary text-primary-content"
          >
            <%= idx %>
          </.link>
        <% else %>
          <.link
            patch={get_route(@channel, @search, idx)}
            class="py-2 px-3 mr-1 text-xl leading-tight rounded text-primary-dark hover:bg-primary hover:text-primary-content"
          >
            <%= idx %>
          </.link>
        <% end %>
      <% end %>

      <%= if @page_number != @total_pages do %>
        <.link
          patch={get_route(@channel, @search, @page_number + 1)}
          class="block py-2 px-3 leading-tight rounded-r-lg hover:bg-primary hover:text-primary-content"
        >
          <span class="sr-only">
            <%= gettext("Next") %>
          </span>
          <svg class="w-6 h-6 text-primary-dark" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path
              fill-rule="evenodd"
              d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
              clip-rule="evenodd"
            >
            </path>
          </svg>
        </.link>
      <% end %>
    </nav>
    """
  end

  defp get_route(channel, search, page_number) do
    params =
      case search do
        nil -> [page: page_number]
        _other -> [page: page_number, search: search]
      end

    case channel do
      nil -> ~p"/?#{params}"
      _other -> ~p"/#{channel}?#{params}"
    end
  end
end
