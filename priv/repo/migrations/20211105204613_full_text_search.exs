defmodule Easypodcasts.Repo.Migrations.FullTextSearch do
  use Ecto.Migration

  use Searchy.Ecto.Migration

  def up do
    alter table(:channels) do
      add(:search_tsvector, :tsvector)
    end

    create_search_for(:channels, [:title, :description], column: :search_tsvector)
    create(index(:channels, [:search_tsvector], using: :gin))
  end

  def down do
    drop(index(:channels, [:search_tsvector]))
    drop_search_for(:channels, [:title, :description])

    alter table(:channels) do
      remove(:search_tsvector)
    end
  end
end
