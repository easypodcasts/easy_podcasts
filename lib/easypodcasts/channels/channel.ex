defmodule Easypodcasts.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  alias Easypodcasts.Processing.Feed

  schema "channels" do
    field :author, :string
    field :description, :string
    field :image_url, :string
    field :link, :string
    field :title, :string
    field :feed_data, :map
    has_many :episodes, Easypodcasts.Channels.Episode

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

  defp append_feed_data(changeset, field, options \\ []) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{link: link}} ->
        case Feed.get_feed_data(link) do
          {:ok, data} ->
            changeset
            # TODO: validate these values
            |> put_change(:author, data["author"]["name"])
            |> put_change(:description, data["description"])
            |> put_change(:image_url, data["image"]["url"])
            |> put_change(:title, data["title"])
            |> put_change(:feed_data, Map.drop(data, ["items"]))

          _ ->
            validate_change(changeset, field, fn _, _link ->
              [{field, options[:message] || "Failed to get and parse feed"}]
            end)
        end

      _ ->
        changeset
    end
  end
end
