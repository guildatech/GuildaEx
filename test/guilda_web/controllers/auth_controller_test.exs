defmodule GuildaWeb.AuthControllerTest do
  use GuildaWeb.ConnCase, async: true

  alias GuildaWeb.AuthController

  @fake_data %{
    "auth_date" => "1610582838",
    "first_name" => "Jefferson",
    "hash" => "2d4f588a2f81a6f98d3c94c73d0d0d83238516701e21949d61cf9a0b5e7e2654",
    "id" => "177382713",
    "last_name" => "Venerando",
    "photo_url" => "https://t.me/i/userpic/320/d5ecPIexRS46x_7El-VmWzY_OLpjz1kPBKg_MeHrroA.jpg",
    "username" => "shamanime"
  }

  describe "verify_telegram_data/1" do
    test "checks if the data received in the parameters are from our bot" do
      {key, _} = AuthController.verify_telegram_data(@fake_data)
      assert key == :ok

      assert {:error, :invalid_telegram_data} ==
               AuthController.verify_telegram_data(%{@fake_data | "first_name" => "unknown"})
    end
  end

  describe "GET /auth/telegram" do
    test "registers an user with valid params", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, @fake_data))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      refute get_flash(conn, :error)
    end

    test "returns an error with invalid params", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, %{@fake_data | "first_name" => "unknown"}))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :error) =~ "Não foi possivel autenticar. Por favor tente novamente mais tarde."
    end
  end
end
