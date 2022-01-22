defmodule Easypodcasts.Repo.Migrations.AddLangToChannel do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add(:lang, :string)
    end
  end
end
