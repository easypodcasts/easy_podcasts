defmodule Easypodcasts.Repo.Migrations.RemoveUniqueIndexAudioUrl do
  use Ecto.Migration

  def change do
    drop index(:episodes, [:original_audio_url])
  end
end
