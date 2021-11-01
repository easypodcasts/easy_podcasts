defmodule Easypodcasts.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :title, :string
      add :link, :string
      add :description, :text
      add :author, :string
      add :image_url, :string

      timestamps()
    end
    create unique_index(:channels, [:link])
  end
end
