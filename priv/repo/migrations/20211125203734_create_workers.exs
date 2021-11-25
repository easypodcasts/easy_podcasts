defmodule Easypodcasts.Repo.Migrations.CreateWorkers do
  use Ecto.Migration

  def change do
    create table(:workers) do
      add :name, :string
      add :token, :string
      add :active, :boolean

      timestamps()
    end
    alter table(:episodes) do
      add :worker_id, references(:workers, on_delete: :nothing)
    end
  end
end
