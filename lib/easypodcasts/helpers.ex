defmodule Easypodcasts.Helpers do
  def slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  def get_page_range(current_page, total_pages) do
    current_page =
      if is_binary(current_page) do
        String.to_integer(current_page)
      else
        current_page
      end

    cond do
      total_pages < 6 ->
        1..total_pages

      current_page <= 3 ->
        1..6

      current_page > 3 and current_page < total_pages - 3 ->
        (current_page - 2)..(current_page + 2)

      current_page >= total_pages - 6 ->
        (total_pages - 6)..total_pages
    end
  end
end
