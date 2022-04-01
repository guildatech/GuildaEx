defmodule GuildaWeb.UserSettingsController do
  use GuildaWeb, :controller

  alias Guilda.Accounts
  alias GuildaWeb.UserAuth

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.audit_context, conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, gettext("Email changed successfully."))
        |> redirect(to: Routes.user_settings_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, gettext("Email change link is invalid or it has expired."))
        |> redirect(to: Routes.user_settings_path(conn, :index))
    end
  end

  def update_password(conn, %{"current_password" => password, "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(conn.assigns.audit_context, user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Password updated successfully."))
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :index))
        |> UserAuth.log_in_user(user)

      _ ->
        conn
        |> put_flash(:error, gettext("We were unable to update your password. Please try again."))
        |> redirect(to: Routes.user_settings_path(conn, :index))
    end
  end
end
