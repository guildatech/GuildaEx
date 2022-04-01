defmodule GuildaWeb.UserTOTPControllerTest do
  use GuildaWeb.ConnCase, async: true

  import Guilda.AccountsFixtures
  @pending :user_totp_pending

  setup %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user) |> put_session(@pending, true)
    %{user: user, totp: user_totp_fixture(user), conn: conn}
  end

  describe "GET /users/totp" do
    test "renders totp page", %{conn: conn} do
      conn = get(conn, Routes.user_totp_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Two-factor authentication</h1>"
    end

    test "redirects to login if not logged in" do
      conn = build_conn()

      assert conn
             |> get(Routes.user_totp_path(conn, :new))
             |> redirected_to() ==
               Routes.user_session_path(conn, :new)
    end

    test "can logout while totp is pending", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Signed out successfully"
    end

    test "redirects to dashboard if totp is not pending", %{conn: conn} do
      assert conn
             |> delete_session(@pending)
             |> get(Routes.user_totp_path(conn, :new))
             |> redirected_to() ==
               Routes.page_path(conn, :index)
    end
  end

  describe "POST /users/totp" do
    test "validates totp", %{conn: conn, totp: totp} do
      code = NimbleTOTP.verification_code(totp.secret)
      conn = post(conn, Routes.user_totp_path(conn, :create), %{"user" => %{"code" => code}})
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_session(conn, @pending) == nil
    end

    test "validates backup code with flash message", %{conn: conn, totp: totp} do
      code = Enum.random(totp.backup_codes).code

      new_conn = post(conn, Routes.user_totp_path(conn, :create), %{"user" => %{"code" => code}})
      assert redirected_to(new_conn) == Routes.page_path(new_conn, :index)
      assert get_session(new_conn, @pending) == nil
      assert get_flash(new_conn, :info) =~ "You have 9 backup codes left"

      # Cannot reuse the code
      new_conn = post(conn, Routes.user_totp_path(conn, :create), %{"user" => %{"code" => code}})
      assert html_response(new_conn, 200) =~ "Invalid two-factor authentication code"
      assert get_session(new_conn, @pending)
    end

    test "logs the user in with return to", %{conn: conn, totp: totp} do
      code = Enum.random(totp.backup_codes).code

      conn =
        conn
        |> put_session(:user_return_to, "/hello")
        |> post(Routes.user_totp_path(conn, :create), %{"user" => %{"code" => code}})

      assert redirected_to(conn) == "/hello"
      assert get_session(conn, @pending) == nil
    end
  end
end
