defmodule Easypodcasts.WorkersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Easypodcasts.Workers` context.
  """

  @doc """
  Generate a worker.
  """
  def worker_fixture(attrs \\ %{}) do
    {:ok, worker} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Easypodcasts.Workers.create_worker()

    worker
  end
end
