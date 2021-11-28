defmodule Easypodcasts.Repo.Migrations.CreateEpisodesIndexes do
  use Ecto.Migration

  def change do
    create index(:episodes, [:status])
    create index(:episodes, [:updated_at])
    create index(:episodes, [:publication_date])
  end
end
