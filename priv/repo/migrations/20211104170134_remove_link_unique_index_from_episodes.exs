defmodule Easypodcasts.Repo.Migrations.RemoveLinkUniqueIndexFromEpisodes do
  use Ecto.Migration

  def change do
    drop index(:episodes, [:link])
  end
end
