defmodule Easypodcasts.Repo.Migrations.AddPublicationDateToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add(:publication_date, :utc_datetime, default: fragment("NOW()"))
    end
  end
end
