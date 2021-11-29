defmodule Easypodcasts.Episodes.Episode do
  use Ecto.Schema

  @behaviour Access

  defdelegate fetch(term, key), to: Map
  defdelegate get(term, key, default), to: Map
  defdelegate get_and_update(term, key, fun), to: Map
  defdelegate pop(term, key), to: Map

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
    field :downloads, :integer, default: 0
    field :guid
    belongs_to :channel, Easypodcasts.Channels.Channel
    belongs_to :worker, Easypodcasts.Workers.Worker

    timestamps()
  end

end
