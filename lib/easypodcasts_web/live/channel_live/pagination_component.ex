defmodule EasypodcastsWeb.PaginationComponent do
  use Phoenix.Component

  alias EasypodcastsWeb.Router.Helpers, as: Routes

  def pagination(
        %{
          socket: socket,
          page_number: page_number,
          total_pages: total_pages,
          is_top: is_top
        } = assigns
      ) do
    ~H"""
    <nav class={nav_classes(is_top)}>

      <%= live_patch to: Routes.channel_index_path(socket, :index, page: page_number - 1 ), class: "block bg-white border border-gray-300 text-gray-500 hover:bg-gray-100 hover:text-gray-700 ml-0 rounded-l-lg leading-tight py-2 px-3 #{if page_number == 1, do: "pointer-events-none text-gray-600"}" do %>
        <span class="sr-only">Previous</span>
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd"></path></svg>
      <% end %>

      <%= for idx <-  Enum.to_list(1..total_pages) do %>
        <%= if page_number == idx do %>
          <%= live_patch idx, to: Routes.channel_index_path(socket, :index, page: idx), class: "bg-blue-50 border border-blue-300 text-blue-600 hover:bg-blue-100 hover:text-blue-700 leading-tight z-10 py-2 px-3 pointer-events-none" %>
        <% else %>
          <%= live_patch idx, to: Routes.channel_index_path(socket, :index, page: idx), class: "bg-white border border-gray-300 text-gray-500 hover:bg-gray-100 hover:text-gray-700 leading-tight py-2 px-3" %>
        <% end %>
      <% end %>

      <%= live_patch to: Routes.channel_index_path(socket, :index, page: page_number + 1), class: "block bg-white border border-gray-300 text-gray-500 hover:bg-gray-100 hover:text-gray-700 rounded-r-lg leading-tight py-2 px-3 #{if page_number <= total_pages, do: "pointer-events-none text-gray-600"}" do %>
        <span class="sr-only">Next</span>
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"></path></svg>
        <% end %>

    </nav>
    """
  end

  defp nav_classes(is_top) do
    if is_top do
      "flex justify-center w-full text-lg mt-5 md:hidden"
    else
      "flex justify-center w-full text-lg mt-5"
    end
  end
end
