defmodule Easypodcasts.Channels.Channel do
  @moduledoc """
  Channel schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Easypodcasts.Helpers.Feed
  alias Easypodcasts.Channels
  import EasypodcastsWeb.Gettext

  schema "channels" do
    field :author, :string
    field :description, :string
    field :image_url, :string
    field :link, :string
    field :title, :string
    field :feed_data, :map
    field :lang, :string
    field :categories, {:array, :string}
    field :blocked, :boolean
    has_many :episodes, Easypodcasts.Episodes.Episode

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:link])
    |> validate_required([:link])
    |> unique_constraint(:link, message: "We have that channel already")
    |> append_feed_data(:link)
    |> validate_denied
  end

  defp validate_denied(changeset) do
    title = get_field(changeset, :title)
    link = get_field(changeset, :link)

    with false <- Channels.denied?(title, link) do
      changeset
    else
      _ ->
        add_error(
          changeset,
          :link,
          gettext(
            "We can't process that podcast right now. Please create an issue with the feed url or visit our support group."
          )
        )
    end
  end

  defp append_feed_data(changeset, field, _options \\ []) do
    with %Ecto.Changeset{valid?: true, changes: %{link: link}} <- changeset,
         {:ok, data} <- Feed.get_feed_data(link) do
      changeset
      |> put_change(:author, data["author"]["name"])
      |> put_change(:description, data["description"])
      |> put_change(:image_url, data["image"]["url"])
      |> put_change(:title, data["title"])
      |> put_change(
        :lang,
        (data["language"] || "") |> String.split("-") |> hd |> String.downcase()
      )
      |> put_change(
        :categories,
        Enum.map(data["categories"] || [], fn c ->
          c |> String.replace(" ", "") |> String.downcase()
        end)
      )
      |> put_change(:feed_data, Map.drop(data, ["items"]))
    else
      {:error, msg} ->
        validate_change(changeset, field, fn _field_name, _link -> [{field, msg}] end)

      changeset ->
        changeset
    end
  end
end
