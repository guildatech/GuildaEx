defmodule GuildaWeb.AuthController do
  use GuildaWeb, :controller

  alias Guilda.Accounts
  alias GuildaWeb.UserAuth

  def telegram_callback(conn, params) do
    with {:ok, params} <- verify_telegram_data(params),
         {:ok, user} <- Accounts.upsert_user(params) do
      UserAuth.log_in_user(conn, user)
    else
      _other ->
        conn
        |> put_flash(:error, gettext("Unable to authenticate. Please try again later."))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def telegram_bot_username do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_username]
  end

  def telegram_bot_token do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_token]
  end

  if Application.get_env(:guilda, :environment) == :dev do
    def verify_telegram_data(params) do
      {:ok, Map.put(params, "telegram_id", params["id"])}
    end
  else
    def verify_telegram_data(params, token \\ nil) do
      {hash, params} = Map.pop(params, "hash")

      secret_key = :crypto.hash(:sha256, token || telegram_bot_token())

      data_check_string = Enum.map_join(params, "\n", fn {k, v} -> "#{k}=#{v}" end)

      hmac = :crypto.mac(:hmac, :sha256, secret_key, data_check_string) |> Base.encode16(case: :lower)

      if hmac == hash do
        {:ok, Map.put(params, "telegram_id", params["id"])}
      else
        {:error, :invalid_telegram_data}
      end
    end
  end
end
