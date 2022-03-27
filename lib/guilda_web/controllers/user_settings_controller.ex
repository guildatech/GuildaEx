defmodule GuildaWeb.UserSettingsController do
  use GuildaWeb, :controller

  alias Guilda.Accounts
  alias GuildaWeb.UserAuth

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def update_password(conn, %{"current_password" => password, "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :index))
        |> UserAuth.log_in_user(user, redirect: false)

      _ ->
        conn
        |> put_flash(:error, "We were unable to update your password. Please try again.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end
end
