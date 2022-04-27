defmodule Easypodcasts.Repo.Migrations.AddBlockedFieldToChannel do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add(:blocked, :boolean, default: false, null: false)
    end
  end
end
