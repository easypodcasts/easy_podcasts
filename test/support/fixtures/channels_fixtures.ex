defmodule Easypodcasts.ChannelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Easypodcasts.Channels` context.
  """

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    {:ok, channel} =
      attrs
      |> Enum.into(%{
        link: "https://easypodcasts.live/feeds/64-thinking-elixir-podcast"
      })
      |> Easypodcasts.Channels.create_channel()

    channel
  end
end
