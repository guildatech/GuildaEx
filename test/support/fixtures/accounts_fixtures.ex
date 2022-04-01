defmodule Guilda.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Guilda.Accounts` context.
  """
  alias Guilda.Accounts
  alias Guilda.Accounts.UserTOTP
  alias Guilda.AuditLog
  alias Guilda.Repo

  @totp_secret Base.decode32!("PTEPUGZ7DUWTBGMW4WLKB6U63MGKKMCA")

  def unique_user_telegram_id, do: System.unique_integer() |> Integer.to_string()
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_totp_secret, do: @totp_secret

  def user_fixture(attrs \\ %{}) do
    {confirmed, attrs} = attrs |> Map.new() |> Map.pop(:confirmed, true)
    {:ok, user} = Accounts.register_user(AuditLog.system(), valid_user_attributes(attrs))

    if confirmed do
      confirm(user)
    else
      user
    end
  end

  def user_totp_fixture(user) do
    %UserTOTP{}
    |> Ecto.Changeset.change(user_id: user.id, secret: valid_totp_secret())
    |> UserTOTP.ensure_backup_codes()
    |> Repo.insert!()
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  defp confirm(user) do
    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_confirmation_instructions(user, url)
      end)

    {:ok, user} = Accounts.confirm_user(token)
    user
  end
end
