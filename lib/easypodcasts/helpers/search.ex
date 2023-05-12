defmodule Easypodcasts.Helpers.Search do
  @moduledoc """
  Postgres full text search helpers
  """
  import Ecto.Query
  import Ecto.Changeset
  alias Easypodcasts.Helpers.Utils

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

  defp search_changeset(attrs) do
    {%{}, %{search_phrase: :string}}
    |> cast(
      attrs,
      [:search_phrase]
    )
    |> validate_required([:search_phrase])
    |> update_change(:search_phrase, &String.trim/1)
    |> validate_length(:search_phrase, min: 2)
    |> validate_format(:search_phrase, ~r/^[A-Za-z0-9\s]*$/)
  end

  def validate_search(search) do
    search_changeset(%{search_phrase: search})
  end

  def parse_search_string(search, allowed_filters \\ [])
  def parse_search_string(nil, _allowed_filters), do: {"", [], []}
  def parse_search_string("", _allowed_filters), do: {"", [], []}

  def parse_search_string(search, allowed_filters) do
    values = String.split(search, " ")
    {filters, values} = Enum.split_with(values, &String.contains?(&1, ":"))

    filters =
      filters
      |> Enum.reduce(%{}, fn filter, acc ->
        [key, value] = String.split(filter, ":")
        Map.put_new(acc, key, value)
      end)
      |> Utils.map_to_keywordlist(allowed_filters)

    {tags, values} = Enum.split_with(values, &String.starts_with?(&1, "#"))
    tags = Enum.map(tags, &String.replace(&1, "#", ""))
    search = Enum.join(values, " ")
    {search, filters, tags}
  end
end
