import Config

# Start the phoenix server if environment is set and running in a release
if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :guilda, GuildaWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :guilda, Guilda.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "guildatech.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :guilda, GuildaWeb.Endpoint,
    url: [scheme: "https", host: host, port: 443],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  telegram_bot_username =
    System.get_env("TELEGRAM_BOT_USERNAME") ||
      raise """
      environment variable TELEGRAM_BOT_USERNAME is missing.
      """

  telegram_bot_token =
    System.get_env("TELEGRAM_BOT_TOKEN") ||
      raise """
      environment variable TELEGRAM_BOT_TOKEN is missing.
      """

  aws_bucket =
    System.get_env("AWS_BUCKET") ||
      raise """
      environment variable AWS_BUCKET is missing.
      """

  aws_region =
    System.get_env("AWS_REGION") ||
      raise """
      environment variable AWS_REGION is missing.
      """

  aws_key_id =
    System.get_env("AWS_ACCESS_KEY_ID") ||
      raise """
      environment variable AWS_ACCESS_KEY_ID is missing.
      """

  aws_secret =
    System.get_env("AWS_SECRET_ACCESS_KEY") ||
      raise """
      environment variable AWS_SECRET_ACCESS_KEY is missing.
      """

  mapbox_access_token =
    System.get_env("MAPBOX_ACCESS_TOKEN") ||
      raise """
      environment variable MAPBOX_ACCESS_TOKEN is missing.
      """

  mailgun_api_key =
    System.get_env("MAILGUN_API_KEY") ||
      raise """
      environment variable MAILGUN_API_KEY is missing.
      """

  mailgun_domain =
    System.get_env("MAILGUN_DOMAIN") ||
      raise """
      environment variable MAILGUN_DOMAIN is missing.
      """

  config :guilda, :auth,
    telegram_bot_username: telegram_bot_username,
    telegram_bot_token: telegram_bot_token

  config :guilda, :maps, access_token: mapbox_access_token

  config :guilda, :aws,
    bucket: aws_bucket,
    region: aws_region,
    access_key_id: aws_key_id,
    secret_access_key: aws_secret

  config :guilda, Guilda.Mailer,
    adapter: Swoosh.Adapters.Mailgun,
    api_key: mailgun_api_key,
    domain: mailgun_domain
end
