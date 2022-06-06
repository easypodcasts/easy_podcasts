defmodule Easypodcasts.Channels.Denylist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "denylist" do
    field :link, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(denylist, attrs) do
    denylist
    |> cast(attrs, [:title, :link])
    |> validate_required([:title, :link])
  end
end
