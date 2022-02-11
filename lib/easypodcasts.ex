defmodule Easypodcasts do
  @moduledoc """
  Easypodcasts keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query
  alias Easypodcasts.Repo
  alias Easypodcasts.Channels.Channel
  alias Easypodcasts.Episodes.Episode

  def get_channels_stats() do
    channels = Repo.one(from(c in Channel, select: count(c)))
    episodes = Repo.one(from(e in Episode, select: count(e)))

    latest_episodes =
      Repo.all(
        from(e in Episode,
          preload: [:channel],
          order_by: [{:desc, e.publication_date}],
          limit: 10
        )
      )

    latest_processed_episodes =
      Repo.all(
        from(e in Episode,
          where: e.status == :done,
          preload: [:channel],
          order_by: [{:desc, e.updated_at}],
          limit: 10
        )
      )

    size_stats =
      Repo.one(
        from(e in Episode,
          where: e.status == :done,
          select: %{
            total: count(e),
            original: sum(e.original_size),
            processed: sum(e.processed_size)
          }
        )
      )

    {channels, episodes, size_stats, latest_episodes, latest_processed_episodes}
  end
end
