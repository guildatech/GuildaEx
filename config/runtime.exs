import Config

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

config :guilda, :auth,
  telegram_bot_username: telegram_bot_username,
  telegram_bot_token: telegram_bot_token

config :guilda, :aws,
  bucket: aws_bucket,
  region: aws_region,
  access_key_id: aws_key_id,
  secret_access_key: aws_secret
