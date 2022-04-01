# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

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

config :guilda, Guilda.Repo,
  types: Guilda.PostgresTypes,
  migration_timestamps: [type: :utc_datetime_usec],
  migration_primary_key: [
    name: :id,
    type: :binary_id,
    autogenerate: false,
    read_after_writes: true,
    default: {:fragment, "gen_random_uuid()"}
  ],
  migration_foreign_key: [type: :binary_id]

config :guilda, :auth,
  telegram_bot_username: System.get_env("TELEGRAM_BOT_USERNAME") || "the_bot_name",
  telegram_bot_token: System.get_env("TELEGRAM_BOT_TOKEN") || "the_bot_token"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws,
  access_key_id: [System.get_env("AWS_ACCESS_KEY_ID"), :instance_role],
  secret_access_key: [System.get_env("AWS_SECRET_ACCESS_KEY"), :instance_role],
  region: System.get_env("AWS_REGION"),
  json_codec: Jason

config :guilda, :aws,
  bucket: System.get_env("S3_BUCKET"),
  region: System.get_env("AWS_REGION"),
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")

config :guilda, :maps, access_token: System.get_env("MAPBOX_ACCESS_TOKEN")

config :ex_gram, adapter: ExGram.Adapter.Tesla

config :gettext, :default_locale, "pt_BR"

config :guilda, GuildaWeb.Gettext,
  split_module_by: [:locale],
  locales: ~w(pt_BR en)

config :guilda, Guilda.Mailer, adapter: Swoosh.Adapters.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
