defmodule GuildaWeb.AuthController do
  use GuildaWeb, :controller

  alias Guilda.Accounts
  alias GuildaWeb.UserAuth

  def telegram_callback(conn, params) do
    params = %{
      "telegram_id" => Map.get(params, "id"),
      "username" => Map.get(params, "username"),
      "first_name" => Map.get(params, "first_name"),
      "last_name" => Map.get(params, "last_name")
    }

    case Accounts.upsert_user(params) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user)

      _other ->
        conn
        |> put_flash(:error, gettext("Não foi possivel autenticar. Por favor tente novamente mais tarde."))
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def telegram_bot_username do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_username]
  end
end
