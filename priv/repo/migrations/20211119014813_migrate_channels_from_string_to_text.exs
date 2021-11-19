defmodule Easypodcasts.Repo.Migrations.MigrateChannelsFromStringToText do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      modify(:title, :text)
      modify(:link, :text)
      modify(:author, :text)
      modify(:image_url, :text)
    end
  end
end
