defmodule Easypodcasts.Helpers.Search do
  import Ecto.Query

  @doc """
  Example Usage:
  where(ecto_query, [table], fragment("? @@ ?", table.tsv_search, to_tsquery(^value)))
  """
  defmacro to_tsquery(query) do
    quote do
      fragment("to_tsquery('english', ?)", unquote(query))
    end
  end

  @doc """
  Example Usage:
  order_by(ecto_query, [table], desc: ts_rank_cd(table.tsv_search, to_tsquery(^value)))
  """
  defmacro ts_rank_cd(tsv, query) do
    quote do
      fragment("ts_rank_cd(?, ?)", unquote(tsv), unquote(query))
    end
  end

  def search(ecto_query, search_query) do
    values = String.split(search_query, " ")

    Enum.reduce(values, ecto_query, &add_search_filter/2)
  end

  defp add_search_filter(value, ecto_query) do
    value = "'#{value}':*"

    where(ecto_query, [table], fragment("? @@ ?", table.tsv_search, to_tsquery(^value)))
  end
end
