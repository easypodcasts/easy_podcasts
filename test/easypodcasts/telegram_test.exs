defmodule Easypodcasts.TelegramTest do
  use Easypodcasts.DataCase

  alias Easypodcasts.Telegram

  describe "subscription" do
    alias Easypodcasts.Telegram.Subscription

    import Easypodcasts.TelegramFixtures

    @invalid_attrs %{}

    test "list_subscription/0 returns all subscription" do
      subscription = subscription_fixture()
      assert Telegram.list_subscription() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Telegram.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      valid_attrs = %{}

      assert {:ok, %Subscription{} = subscription} = Telegram.create_subscription(valid_attrs)
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Telegram.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      update_attrs = %{}

      assert {:ok, %Subscription{} = subscription} = Telegram.update_subscription(subscription, update_attrs)
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Telegram.update_subscription(subscription, @invalid_attrs)
      assert subscription == Telegram.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Telegram.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Telegram.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Telegram.change_subscription(subscription)
    end
  end
end
