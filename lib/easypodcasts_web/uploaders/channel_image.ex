defmodule Easypodcasts.ChannelImage do
  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  # use Waffle.Ecto.Definition

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   file_extension = file.file_name |> Path.extname() |> String.downcase()
  #
  #   case Enum.member?(~w(.jpg .jpeg .gif .png), file_extension) do
  #     true -> :ok
  #     false -> {:error, "invalid file type"}
  #   end
  # end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 215x215^ -gravity center -extent 215x215", :webp}
  end

  def transform(:original, _) do
    {:convert, "-sampling-factor 4:2:0 -strip -quality 85 -colorspace RGB", :webp}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  def storage_dir_prefix() do
    "priv/static/images"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, channel}) do
    "channels/#{channel.id}"
  end

  def url({file, channel}, _version, _options) do
    if Mix.env() == :prod do
      "/podcasts/images/channels/#{channel.id}/#{file}"
    else
      "/images/channels/#{channel.id}/#{file}"
    end
  end
end
