defmodule Easypodcasts.Telegram do
  @moduledoc """
  The Telegram context.
  """

  import Ecto.Query, warn: false
  alias Easypodcasts.Repo

  alias Easypodcasts.Telegram.{Subscription, ChannelSubscription}

  @doc """
  Returns the list of subscription.

  ## Examples

      iex> list_subscription()
      [%Subscription{}, ...]

  """
  def list_subscription do
    Repo.all(Subscription)
  end

  def list_subscribed_new_podcasts do
    from(s in Subscription, where: s.new_podcasts == true, select: s.chat_id) |> Repo.all()
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  def get_subscription(id), do: Repo.get(Subscription, id)

  def get_subscription_by_chat_id(chat_id) when is_integer(chat_id) do
    Repo.get_by(Subscription, chat_id: Integer.to_string(chat_id)) |> Repo.preload(:channels)
  end

  def get_subscription_by_chat_id(chat_id) when is_binary(chat_id) do
    Repo.get_by(Subscription, chat_id: chat_id)
  end

  def is_subscribed_new_podcasts(chat_id) do
    case get_subscription_by_chat_id(chat_id) do
      %{new_podcasts: new_podcasts} -> new_podcasts
      nil -> false
    end
  end

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.update_changeset(attrs)
    |> Repo.update()
  end

  def update_podcast_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.update_subscription_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  def delete_channel_subscription(subscription_id, channel_id) do
    Repo.delete_all(
      from c in ChannelSubscription,
        where: c.subscription_id == ^subscription_id and c.channel_id == ^channel_id
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end
end
