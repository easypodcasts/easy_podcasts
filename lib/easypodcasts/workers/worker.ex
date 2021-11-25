defmodule Easypodcasts.Workers.Worker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workers" do
    field :name, :string
    field :token, :string
    field :active, :boolean
    has_many :episodes, Easypodcasts.Channels.Episode

    timestamps()
  end

  @doc false
  def changeset(worker, attrs) do
    worker
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
