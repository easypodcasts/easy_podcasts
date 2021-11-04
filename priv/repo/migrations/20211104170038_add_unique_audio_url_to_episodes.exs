defmodule Easypodcasts.Repo.Migrations.AddUniqueAudioUrlToEpisodes do
  use Ecto.Migration

  def change do
    create unique_index(:episodes, [:original_audio_url])
  end
end
