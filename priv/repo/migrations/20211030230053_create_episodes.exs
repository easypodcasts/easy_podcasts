defmodule Easypodcasts.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :title, :string
      add :link, :string
      add :description, :text
      add :original_audio_url, :string
      add :processed, :boolean, default: false, null: false
      add :processed_audio_url, :string
      add :original_size, :integer
      add :processed_size, :integer
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:episodes, [:link])
  end
end
