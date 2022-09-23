defmodule Easypodcasts.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :chat_id, :string
      add :new_podcasts, :boolean, default: false

      timestamps()
    end

    create unique_index(:subscriptions, [:chat_id])
  end
end
