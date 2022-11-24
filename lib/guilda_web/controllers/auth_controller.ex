defmodule GuildaWeb.AuthController do
  use GuildaWeb, :controller

  alias Guilda.Accounts
  alias GuildaWeb.UserAuth

  # credo:disable-for-next-line
  def telegram_callback(conn, params) do
    case verify_telegram_data(params, get_session(conn, :telegram_bot_token)) do
      {:ok, params} ->
        user = conn.assigns.current_user
        user_from_telegram_params = Accounts.get_user_by_telegram_id(params["telegram_id"])

        cond do
          user && user.telegram_id ->
            # User is signed in and already connected a Telegram account
            conn
            |> put_flash(:error, gettext("You already connected a Telegram account."))
            |> redirect(to: Routes.user_settings_path(conn, :index))

          user && !user_from_telegram_params ->
            # User is signed in and there's no other account with the same Telegram ID
            # credo:disable-for-next-line
            case Accounts.connect_provider(conn.assigns.audit_context, user, :telegram, params["telegram_id"]) do
              {:ok, _user} ->
                conn
                |> put_flash(:info, gettext("Successfully connected your Telegram account."))
                |> redirect(to: Routes.user_settings_path(conn, :index))

              _ ->
                conn
                |> put_flash(:error, gettext("Failed to connect your Telegram account."))
                |> redirect(to: Routes.user_settings_path(conn, :index))
            end

          !user && user_from_telegram_params ->
            # User is not signed in and there is an account for the given Telegram ID
            conn
            |> UserAuth.log_in_user(user_from_telegram_params)
            |> UserAuth.redirect_user_after_login()

          true ->
            # User is not signed in and there is no account for the given Telegram ID
            conn
            |> put_flash(:error, gettext("You must register or sign in before connecting a Telegram account."))
            |> redirect(to: Routes.user_registration_path(conn, :new))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("Unable to authenticate. Please try again later."))
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end

  def telegram_bot_username do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_username]
  end

  def telegram_bot_token do
    Application.fetch_env!(:guilda, :auth)[:telegram_bot_token]
  end

  if Application.compile_env(:guilda, :environment) == :dev do
    def verify_telegram_data(params, _token \\ nil) do
      {:ok, Map.put(params, "telegram_id", params["id"])}
    end
  else
    def verify_telegram_data(params, token \\ nil) do
      {hash, params} = Map.pop(params, "hash")

      secret_key = :crypto.hash(:sha256, token || telegram_bot_token())

      data_check_string = Enum.map_join(params, "\n", fn {k, v} -> "#{k}=#{v}" end)

      hmac = :crypto.mac(:hmac, :sha256, secret_key, data_check_string) |> Base.encode16(case: :lower)

      if hmac == hash do
        {:ok, Map.put(params, "telegram_id", params["id"])}
      else
        {:error, :invalid_telegram_data}
      end
    end
  end
end
