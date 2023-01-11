defmodule Easypodcasts.Repo.Migrations.CreateDonations do
  use Ecto.Migration

  def change do
    create table(:donations) do
      add :from, :string
      add :amount, :decimal

      timestamps()
    end
  end
end
