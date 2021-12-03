defmodule Easypodcasts.Episodes.EpisodeAudio do
  @moduledoc """
  Episode audio uploader
  """
  use Waffle.Definition

  @versions [:original]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

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
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  def storage_dir_prefix() do
    "uploads"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, episode}) do
    # "uploads/user/avatars/#{scope.id}"
    "#{episode.channel_id}/episodes/#{episode.id}"
  end
end
