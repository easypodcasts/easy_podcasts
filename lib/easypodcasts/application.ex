defmodule Easypodcasts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Easypodcasts.Repo,
      # Start the Telemetry supervisor
      EasypodcastsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Easypodcasts.PubSub},
      # Start the Endpoint (http/https)
      EasypodcastsWeb.Endpoint,
      EasypodcastsWeb.Presence,
      # Start a worker by calling: Easypodcasts.Worker.start_link(arg)
      # {Easypodcasts.Worker, arg}
      {Task.Supervisor, name: Easypodcasts.TaskSupervisor},
      Easypodcasts.Scheduler,
      {Registry, keys: :unique, name: WorkerRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: WorkerSupervisor},
      Easypodcasts.Queue,
      {Telegram.Poller,
       bots: [
         {Easypodcasts.Bot.Counter,
          token: Application.get_env(:easypodcasts, Easypodcasts)[:telegram_token],
          max_bot_concurrency: 1000}
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Easypodcasts.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EasypodcastsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
