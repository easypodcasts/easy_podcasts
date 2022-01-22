defmodule Easypodcasts.Repo.Migrations.AddCategoriesToEpisode do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add(:categories, {:array, :string})
    end
  end
end
