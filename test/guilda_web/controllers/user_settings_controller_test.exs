defmodule GuildaWeb.UserSettingsControllerTest do
  use GuildaWeb.ConnCase, async: true
  import Ecto.Query
  import Guilda.AccountsFixtures
  alias Guilda.Accounts
  alias Guilda.Accounts.User
  alias Guilda.AuditLog
  alias Guilda.Repo

  setup :register_and_log_in_user

  setup %{user: %{id: id} = user} do
    user = %{user | email: unique_user_email()}

    from(u in User, where: u.id == ^id)
    |> Repo.update_all(set: [email: user.email])

    %{user: user}
  end

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(AuditLog.system(), %{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :index)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute get_user_by_email(user.email)
      assert get_user_by_email(email)

      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :index)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :index)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end
end
