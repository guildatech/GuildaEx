defmodule GuildaWeb.AuthControllerTest do
  use GuildaWeb.ConnCase, async: true

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

  describe "GET /auth/telegram" do
    test "registers an user with valid params", %{conn: conn} do
      {_token, params} = @jefferson
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, params))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      refute get_flash(conn, :error)
    end

    test "returns an error with invalid params", %{conn: conn} do
      {_token, params} = @jefferson
      conn = get(conn, Routes.auth_path(conn, :telegram_callback, %{params | "first_name" => "unknown"}))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert get_flash(conn, :error) =~ "Não foi possivel autenticar. Por favor tente novamente mais tarde."
    end
  end
end
