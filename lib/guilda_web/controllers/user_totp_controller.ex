defmodule GuildaWeb.UserTOTPController do
  use GuildaWeb, :controller

  alias Guilda.Accounts
  alias GuildaWeb.UserAuth

  plug :redirect_if_totp_is_not_pending

  @pending :user_totp_pending

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    audit_context = conn.assigns.audit_context
    current_user = conn.assigns.current_user

    case Accounts.validate_user_totp(audit_context, current_user, user_params["code"]) do
      :valid_totp ->
        conn
        |> delete_session(@pending)
        |> UserAuth.redirect_user_after_login(user_params)

      {:valid_backup_code, remaining} ->
        plural = ngettext("backup code", "backup codes", remaining)

        conn
        |> delete_session(@pending)
        |> put_flash(
          :info,
          "You have #{remaining} #{plural} left. " <>
            "You can generate new ones under the Two-factor authentication section in the Settings page"
        )
        |> UserAuth.redirect_user_after_login(user_params)

      :invalid ->
        render(conn, "new.html", error_message: "Invalid two-factor authentication code")
    end
  end

  defp redirect_if_totp_is_not_pending(conn, _opts) do
    if get_session(conn, @pending) do
      conn
    else
      conn
      |> UserAuth.redirect_user_after_login()
      |> halt()
    end
  end
end
