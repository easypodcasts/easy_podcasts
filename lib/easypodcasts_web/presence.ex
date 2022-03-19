defmodule EasypodcastsWeb.Presence do
  use Phoenix.Presence, otp_app: :easypodcasts, pubsub_server: Easypodcasts.PubSub

  def on_mount(:default, _params, session, socket) do
    if Phoenix.LiveView.connected?(socket) do
      {:ok, _} = track(self(), "visitors", session["_csrf_token"], %{})
    end

    {:cont, socket}
  end
end
