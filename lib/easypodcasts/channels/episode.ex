defmodule Easypodcasts.Channels.Episode do
  use Ecto.Schema

  schema "episodes" do
    field :description, :string
    field :link, :string
    field :original_audio_url, :string
    field :original_size, :integer
    field :processed, :boolean, default: false
    field :processed_audio_url, :string
    field :processed_size, :integer
    field :title, :string
    field :publication_date, :utc_datetime
    belongs_to :channel, Easypodcasts.Channels.Channel

    timestamps()
  end

end
