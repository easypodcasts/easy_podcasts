defmodule Easypodcasts.Channels.Channel do
  @moduledoc """
  Channel schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Easypodcasts.Helpers.Feed

  schema "channels" do
    field :author, :string
    field :description, :string
    field :image_url, :string
    field :link, :string
    field :title, :string
    field :feed_data, :map
    field :lang, :string
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
  end

  defp append_feed_data(changeset, field, _options \\ []) do
    with %Ecto.Changeset{valid?: true, changes: %{link: link}} <- changeset,
         {:ok, data} <- Feed.get_feed_data(link) do
      changeset
      |> put_change(:author, data["author"]["name"])
      |> put_change(:description, data["description"])
      |> put_change(:image_url, data["image"]["url"])
      |> put_change(:title, data["title"])
      |> put_change(:lang, data["language"])
      |> put_change(:feed_data, Map.drop(data, ["items"]))
    else
      {:error, msg} ->
        validate_change(changeset, field, fn _field_name, _link -> [{field, msg}] end)

      changeset ->
        changeset
    end
  end
end
