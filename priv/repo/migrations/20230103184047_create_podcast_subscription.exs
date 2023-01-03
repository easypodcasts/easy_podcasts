defmodule Easypodcasts.Repo.Migrations.CreatePodcastSubscription do
  use Ecto.Migration

  def change do
    create table(:channel_subscriptions) do
      add(:subscription_id, references(:subscriptions))
      add(:channel_id, references(:channels))
      timestamps()
    end
  end
end
