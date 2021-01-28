import Config

config :guilda, :environment, :prod

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

config :guilda, :auth,
  telegram_bot_username: telegram_bot_username,
  telegram_bot_token: telegram_bot_token

config :guilda, :aws,
  bucket: System.fetch_env!("AWS_BUCKET"),
  region: System.fetch_env!("AWS_REGION"),
  access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
