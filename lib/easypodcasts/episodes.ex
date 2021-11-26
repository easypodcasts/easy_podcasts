defmodule Easypodcasts.Episodes do
  @moduledoc """
  The Episodes context.
  """

  import Ecto.Query, warn: false
  alias Easypodcasts.Repo

  alias Easypodcasts.Episodes.Episode

  def get_queued_episodes(),
    do: from(e in Episode, where: e.status in [:queued, :processing]) |> Repo.all()
end
