defmodule EasypodcastsWeb.Locale.Plug do
  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    accepted_languages = extract_accept_language(conn)
    known_locales = Gettext.known_locales(EasypodcastsWeb.Gettext)

    accepted_languages = Enum.filter(accepted_languages, &(&1 in known_locales))

    case accepted_languages do
      [locale | _] ->
        Gettext.put_locale(EasypodcastsWeb.Gettext, locale)

        conn
        |> put_session(:locale, locale)

      _ ->
        conn
    end
  end

  # Copied from
  # https://raw.githubusercontent.com/smeevil/set_locale/fd35624e25d79d61e70742e42ade955e5ff857b8/lib/headers.ex
  def extract_accept_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> ensure_language_fallbacks()

      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp ensure_language_fallbacks(tags) do
    Enum.flat_map(tags, fn tag ->
      case String.split(tag, "-") do
        [language, _country_variant] ->
          if Enum.member?(tags, language), do: [tag], else: [tag, language]

        [_language] ->
          [tag]
      end
    end)
  end

  def on_mount(:default, _params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EasypodcastsWeb.Gettext, locale)
    {:cont, socket}
  end
end
