defmodule Easypodcasts.Telegram.ChannelSubscription do
  use Ecto.Schema

  schema "channel_subscriptions" do
    belongs_to :subscription, Easypodcasts.Telegram.Subscription
    belongs_to :channel, Easypodcasts.Channels.Channel
    timestamps()
  end
end

defmodule Easypodcasts.Telegram.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :chat_id, :string
    field :new_podcasts, :boolean, default: false

    many_to_many :channels, Easypodcasts.Channels.Channel,
      join_through: Easypodcasts.Telegram.ChannelSubscription

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:chat_id, :new_podcasts])
    |> validate_required([:chat_id])
  end

  @doc false
  def update_changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:new_podcasts])
    |> validate_required([:new_podcasts])
  end

  def update_subscription_changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> put_assoc(:channels, [attrs.channel | subscription.channels])
  end
end
