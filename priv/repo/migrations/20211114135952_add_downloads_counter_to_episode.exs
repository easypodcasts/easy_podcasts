defmodule Easypodcasts.Repo.Migrations.AddDownloadsCounterToEpisode do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :downloads, :integer, default: 0
    end
  end
end
