defmodule Easypodcasts.Repo.Migrations.AddLastEpisodeProcessedAtToWorker do
  use Ecto.Migration

  def change do
    alter table(:workers) do
      add(:last_episode_processed_at, :utc_datetime)
    end
  end
end
