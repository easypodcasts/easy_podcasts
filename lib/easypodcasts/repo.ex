defmodule Easypodcasts.Repo do
  use Ecto.Repo,
    otp_app: :easypodcasts,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 15
end
