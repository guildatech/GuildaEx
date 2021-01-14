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
        |> put_flash(:error, gettext("Não foi possivel autenticar. Por favor tente novamente mais tarde."))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def telegram_bot_username do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_username]
  end

  def telegram_bot_token do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_token]
  end

  def verify_telegram_data(params) do
    params = %{
      auth_date: Map.get(params, "auth_date"),
      first_name: Map.get(params, "first_name"),
      id: Map.get(params, "id"),
      hash: Map.get(params, "hash"),
      last_name: Map.get(params, "last_name"),
      photo_url: Map.get(params, "photo_url"),
      username: Map.get(params, "username")
    }

    secret_key = :crypto.hash(:sha256, telegram_bot_token())

    data_check_string =
      params
      |> Map.drop([:hash])
      |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
      |> Enum.join("\n")

    hmac = :crypto.hmac(:sha256, secret_key, data_check_string) |> Base.encode16(case: :lower)

    if hmac == params.hash do
      {:ok, Map.put(params, :telegram_id, params.id)}
    else
      {:error, :invalid_telegram_data}
    end
  end
end
