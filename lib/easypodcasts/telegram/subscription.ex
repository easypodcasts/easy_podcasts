defmodule Easypodcasts.Telegram.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :chat_id, :string
    field :new_podcasts, :boolean, default: false
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
end
