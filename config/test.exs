import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :guilda, Guilda.Repo,
  username: "postgres",
  password: "postgres",
  database: "guilda_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :guilda, GuildaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :guilda, :auth, telegram_bot_token: "1328041770:AAG7GlDdKF2FVEmYjHFNNFKj9UVhDOKmtqc"

config :guilda, :environment, :test
