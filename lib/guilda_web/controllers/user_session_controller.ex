defmodule GuildaWeb.UserSessionController do
  use GuildaWeb, :controller

  alias GuildaWeb.UserAuth

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext("Logout efetuado com sucesso."))
    |> UserAuth.log_out_user()
  end
end
