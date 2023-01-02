defmodule Easypodcasts.TelegramFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Easypodcasts.Telegram` context.
  """

  @doc """
  Generate a subscription.
  """
  def subscription_fixture(attrs \\ %{}) do
    {:ok, subscription} =
      attrs
      |> Enum.into(%{})
      |> Easypodcasts.Telegram.create_subscription()

    subscription
  end
end
