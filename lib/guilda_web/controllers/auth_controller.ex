defmodule GuildaWeb.AuthController do
  use GuildaWeb, :controller

  def telegram_callback(conn, params) do
    IO.inspect(params)

    conn
    |> put_flash(:error, gettext("Não foi possivel autenticar. Por favor tente novamente mais tarde."))
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def telegram_bot_username() do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_username]
  end
end
