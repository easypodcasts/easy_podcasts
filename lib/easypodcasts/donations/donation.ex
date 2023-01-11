defmodule Easypodcasts.Donations.Donation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "donations" do
    field :amount, :decimal
    field :from, :string, default: "Anónimo"

    timestamps()
  end

  @doc false
  def changeset(donation, attrs) do
    donation
    |> cast(attrs, [:from, :amount])
    |> validate_required([:from, :amount])
  end
end
