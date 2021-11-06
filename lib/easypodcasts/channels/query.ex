defmodule Easypodcasts.Channels.Query do
  import Ecto.Query
  alias Easypodcasts.Channels.Episode

  def channels_with_episode_count(queryable) do
    from(c in queryable,
      left_join: e in Episode,
      on: c.id == e.channel_id,
      group_by: c.id,
      select_merge: %{episodes: count(e.id)},
      order_by: [desc: c.inserted_at]
    )
  end
end
