defmodule Easypodcasts.Repo.Migrations.AddCanProcessBlockedToWorker do
  use Ecto.Migration

  def change do
    alter table(:workers) do
      add(:can_process_blocked, :boolean, default: false, null: false)
    end
  end
end
