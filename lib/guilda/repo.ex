defmodule Guilda.Repo do
  use Ecto.Repo,
    otp_app: :guilda,
    adapter: Ecto.Adapters.Postgres
end
