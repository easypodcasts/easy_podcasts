defmodule Easypodcasts.DonationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Easypodcasts.Donations` context.
  """

  @doc """
  Generate a donation.
  """
  def donation_fixture(attrs \\ %{}) do
    {:ok, donation} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        from: "some from"
      })
      |> Easypodcasts.Donations.create_donation()

    donation
  end
end
