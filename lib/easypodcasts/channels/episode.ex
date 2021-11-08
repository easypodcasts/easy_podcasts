defmodule Easypodcasts.Channels.Episode do
  use Ecto.Schema

  schema "episodes" do
    field :description, :string
    field :link, :string
    field :original_audio_url, :string
    field :original_size, :integer
    field :status, Ecto.Enum, values: [:new, :queued, :processing, :done], default: :new
    field :processed_audio_url, :string
    field :processed_size, :integer
    field :title, :string
    field :publication_date, :utc_datetime
    field :feed_data, :map
    belongs_to :channel, Easypodcasts.Channels.Channel

    timestamps()
  end
end
