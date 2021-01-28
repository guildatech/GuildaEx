defmodule Guilda.Repo do
  use Ecto.Repo,
    otp_app: :guilda,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    if config[:load_from_system_env] do
      db_url =
        System.get_env("DATABASE_URL") ||
          raise """
          environment variable DATABASE_URL is missing.
          For example: ecto://USER:PASS@HOST/DATABASE
          """

      config = Keyword.put(config, :url, db_url)

      {:ok, config}
    else
      {:ok, config}
    end
  end
end
