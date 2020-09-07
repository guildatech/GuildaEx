defmodule Guilda.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Guilda.Accounts` context.
  """

  def unique_user_telegram_id, do: System.unique_integer() |> Integer.to_string()
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        telegram_id: unique_user_telegram_id(),
        username: "username",
        first_name: "First Name",
        last_name: "Last Name",
        email: nil
      })
      |> Guilda.Accounts.upsert_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
