defmodule Easypodcasts.Repo.Migrations.AddFeedDataToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :feed_data, :map
    end
  end
end
