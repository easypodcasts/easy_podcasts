defmodule Easypodcasts.Repo.Migrations.CreateDenylist do
  use Ecto.Migration

  def change do
    create table(:denylist) do
      add :title, :string
      add :link, :string

      timestamps()
    end
  end
end
