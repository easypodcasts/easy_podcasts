defmodule Easypodcasts.Channels.ChannelImage do
  @moduledoc """
  Uploader for channel images
  """
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
  def transform(:thumb, _file) do
    {:ffmpeg, &"-i #{&1} -vf scale=215x215 -f webp #{&2}", :webp}
  end

  def transform(:original, _file) do
    {:ffmpeg, &"-i #{&1} -vf scale=400x400 -f webp #{&2}", :webp}
  end

  # Override the persisted filenames:
  def filename(version, _file) do
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
    "/images/channels/#{channel.id}/#{file}"
  end
end
