defmodule GuildaWeb.AuthControllerTest do
  use GuildaWeb.ConnCase, async: true

  alias Guilda.Accounts
  alias Guilda.AccountsFixtures
  alias Guilda.AuditLog
  alias GuildaWeb.AuthController

  @jefferson {"1328041770:AAG7GlDdKF2FVEmYjHFNNFKj9UVhDOKmtqc",
              %{
                "auth_date" => "1610582838",
                "first_name" => "Jefferson",
                "hash" => "2d4f588a2f81a6f98d3c94c73d0d0d83238516701e21949d61cf9a0b5e7e2654",
                "id" => "177382713",
                "last_name" => "Venerando",
                "photo_url" => "https://t.me/i/userpic/320/d5ecPIexRS46x_7El-VmWzY_OLpjz1kPBKg_MeHrroA.jpg",
                "username" => "shamanime"
              }}

  @duran {"1328041770:AAG01XO_6mrceJHvNtxKaXsrX2FsvCgHJIU",
          %{
            "auth_date" => "1611881130",
            "first_name" => "Duran, o anão",
            "hash" => "5c4eb4569880b94e7ab5b0d5d44ab73c6cb04f9535add891f9fed694aca594dc",
            "id" => "89289679",
            "username" => "Duran_the_hutt"
          }}

  setup do
    conn = build_conn() |> Plug.Test.init_test_session(%{})
    %{conn: conn}
  end

  describe "verify_telegram_data/1" do
    test "checks if the data received in the parameters are from our bot" do
      {token, params} = @jefferson
      {key, _} = AuthController.verify_telegram_data(params, token)
      assert key == :ok

      assert {:error, :invalid_telegram_data} ==
               AuthController.verify_telegram_data(%{params | "first_name" => "unknown"}, token)

      {token, params} = @duran
      {key, _} = AuthController.verify_telegram_data(params, token)
      assert key == :ok

      assert {:error, :invalid_telegram_data} ==
               AuthController.verify_telegram_data(%{params | "first_name" => "unknown"}, token)
    end
  end

  describe "GET /auth/telegram/callback" do
    test "logs in an user already connected to a Telegram account", %{conn: conn} do
      {token, params} = @jefferson
      user = AccountsFixtures.user_fixture()
      {:ok, _user} = Accounts.connect_provider(AuditLog.system(), user, :telegram, params["id"])
      conn = put_session(conn, :telegram_bot_token, token)
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, params))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      refute get_flash(conn, :error)
    end

    test "redirects if user is signed in and already connected to a Telegram account", %{conn: conn} do
      {token, params} = @jefferson
      user = AccountsFixtures.user_fixture()
      {:ok, user} = Accounts.connect_provider(AuditLog.system(), user, :telegram, params["id"])
      conn = log_in_user(conn, user)
      conn = put_session(conn, :telegram_bot_token, token)
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, params))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "You already connected a Telegram account."
    end

    test "updates the user if it is signed in and not connected to Telegram", %{conn: conn} do
      {token, params} = @jefferson
      user = AccountsFixtures.user_fixture()
      conn = log_in_user(conn, user)
      conn = put_session(conn, :telegram_bot_token, token)
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, params))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Successfully connected your Telegram account."
    end

    test "redirects if user is not signed in and no connected account was found", %{conn: conn} do
      {token, params} = @jefferson
      conn = put_session(conn, :telegram_bot_token, token)
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, params))
      assert redirected_to(conn) == Routes.user_registration_path(conn, :new)
      assert get_flash(conn, :error) =~ "You must register or sign in before connecting a Telegram account."
    end

    test "returns an error with invalid params", %{conn: conn} do
      {_token, params} = @jefferson
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, %{params | "first_name" => "unknown"}))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :error) =~ "Unable to authenticate. Please try again later."
    end
  end
end
