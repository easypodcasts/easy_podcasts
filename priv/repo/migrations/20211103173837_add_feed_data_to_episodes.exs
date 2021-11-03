defmodule Easypodcasts.Repo.Migrations.AddFeedDataToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :feed_data, :map
    end
  end
end
