defmodule Easypodcasts.Repo.Migrations.MigrateEpisodesFromStringToText do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      modify :title, :text
      modify :link, :text
      modify :original_audio_url, :text
      modify :processed_audio_url, :text
    end
  end
end
