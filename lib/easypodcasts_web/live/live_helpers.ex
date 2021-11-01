defmodule EasypodcastsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `EasypodcastsWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal EasypodcastsWeb.ChannelLive.FormComponent,
        id: @channel.id || :new,
        action: @live_action,
        channel: @channel,
        return_to: Routes.channel_index_path(@socket, :index) %>
  """
  def live_form(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(EasypodcastsWeb.FormComponent, modal_opts)
  end
end
