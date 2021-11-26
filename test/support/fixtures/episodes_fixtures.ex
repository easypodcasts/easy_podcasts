defmodule Easypodcasts.EpisodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Easypodcasts.Episodes` context.
  """

  @doc """
  Generate a episode.
  """
  def episode_fixture(attrs \\ %{}) do
    {:ok, episode} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Easypodcasts.Episodes.create_episode()

    episode
  end
end
