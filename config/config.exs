# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :guilda,
  ecto_repos: [Guilda.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :guilda, GuildaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5wynN+FiYcqfUIm9PO+qzWCJOsOXTirWFMBh9qZ0rJ7n4C30Mw+hg5nH1wGhg057",
  render_errors: [view: GuildaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Guilda.PubSub,
  live_view: [signing_salt: "E3IrZAj7"]

config :guilda, Guidla.Repo,
  migration_timestamps: [type: :utc_datetime_usec],
  migration_primary_key: [
    name: :id,
    type: :binary_id,
    autogenerate: false,
    read_after_writes: true,
    default: {:fragment, "gen_random_uuid()"}
  ]

config :guilda, :auth, telegram_bot_username: "guilda_tech_bot"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
