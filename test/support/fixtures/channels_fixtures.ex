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

  @doc """
  Generate a episode.
  """
  def episode_fixture(attrs \\ %{}) do
    {:ok, episode} =
      attrs
      |> Enum.into(%{
        description: "some description",
        link: "some link",
        original_audio_url: "some original_audio_url",
        original_size: 42,
        processed: true,
        processed_audio_url: "some processed_audio_url",
        processed_size: 42,
        title: "some title"
      })
      |> Easypodcasts.Channels.create_episode()

    episode
  end
end
