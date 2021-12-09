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
        author: "some author",
        description: "some description",
        image_url: "some image_url",
        link: "some link",
        title: "some title"
      })
      |> Easypodcasts.Channels.create_channel()

    channel
  end
end
