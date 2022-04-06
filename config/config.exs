# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :easypodcasts,
  ecto_repos: [Easypodcasts.Repo]

# Configures the endpoint
config :easypodcasts, EasypodcastsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: EasypodcastsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Easypodcasts.PubSub,
  live_view: [signing_salt: "lLqSpypW"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :easypodcasts, Easypodcasts.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# i80n
config :easypodcasts, EasypodcastsWeb.Gettext,
  default_locale: "es",
  locales: ~w(es en fr de pt eo)

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --chunk-names=chunks/[name]-[hash] --bundle --outdir=../priv/static/assets --splitting --format=esm --target=es2016),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind
config :tailwind,
  version: "3.0.23",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
