defmodule Easypodcasts.Repo.Migrations.AddRetriesAndReportsToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :retries, :integer, default: 0
      add :reports, :integer, default: 0
    end
  end
end
