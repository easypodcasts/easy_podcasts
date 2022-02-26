defmodule Easypodcasts.Helpers.Utils do
  @moduledoc """
  Misc helpers
  """

  def slugify(thing) when is_binary(thing) do
    thing
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  def slugify(thing) do
    "#{thing.id}-#{slugify(thing.title)}"
  end

  def get_page_range(current_page, total_pages) when is_binary(current_page) do
    current_page |> String.to_integer() |> get_page_range(total_pages)
  end

  def get_page_range(current_page, total_pages) do
    current_page =
      if is_binary(current_page) do
        String.to_integer(current_page)
      else
        current_page
      end

    cond do
      total_pages <= 5 ->
        1..total_pages

      current_page <= 3 ->
        1..5

      current_page > 3 and current_page < total_pages - 3 ->
        (current_page - 2)..(current_page + 2)

      current_page >= total_pages - 3 ->
        (total_pages - 4)..total_pages
    end
  end

  def get_file_size(file) do
    {:ok, %{size: size}} = File.stat(file)
    size
  end

  def get_audio_duration(path) do
    case System.cmd("ffprobe", [
           path,
           "-show_entries",
           "format=duration",
           "-v",
           "quiet",
           "-of",
           "csv=p=0",
           "-user_agent",
           "'Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0'"
         ]) do
      {duration, 0} -> duration |> String.trim() |> String.to_float() |> trunc
      _ -> 0
    end
  end

  def format_date(date) do
    localized = DateTime.shift_zone!(date, "America/Havana")
    Calendar.strftime(localized, "%B %d, %Y")
  end

  def get_duration(episode) do
    case episode.feed_data["extensions"]["itunes"]["duration"] do
      [head | _] ->
        head
        |> Map.get("value")
        |> format_duration

      _ ->
        "00:00"
    end
  end

  def format_duration("") do
    "00:00"
  end

  def format_duration(duration) when is_binary(duration) do
    cond do
      String.contains?(duration, ":") -> duration
      String.contains?(duration, ".") -> duration |> String.to_float() |> trunc |> format_duration
      true -> format_duration(String.to_integer(duration))
    end
  end

  def format_duration(duration) when is_integer(duration) do
    time = Time.add(Time.new!(0, 0, 0), duration)
    "#{time.hour}:#{time.minute}:#{time.second}"
  end

  def map_to_keywordlist(map, keys) do
    map
    |> Map.take(keys)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end
end
