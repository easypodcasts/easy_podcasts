defmodule Easypodcasts.Repo.Migrations.AddStatusToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add(:status, :string, default: "new")
      remove :processed
    end
  end
end
