defmodule Easypodcasts.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  alias Easypodcasts.Channels.DataProcess

  schema "channels" do
    field :author, :string
    field :description, :string
    field :image_url, :string
    field :link, :string
    field :title, :string
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
        case DataProcess.get_channel_data(link) do
          {:ok, data} ->
            changeset
            |> put_change(:author, data.itunes_author)
            |> put_change(:description, data.description)
            |> put_change(:image_url, data.itunes_image)
            |> put_change(:title, data.title)

          {:error, message} ->
            validate_change(changeset, field, fn _, _link ->
              [{field, options[:message] || message}]
            end)
        end

      _ ->
        changeset
    end
  end
end
