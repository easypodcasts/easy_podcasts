defmodule Easypodcasts.Repo.Migrations.AddCategoriesToChannel do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add(:categories, {:array, :string})
    end
  end
end
