defmodule Guilda.Finances.Policy do
  @moduledoc """
  Authorization policy for the Finances context.
  """
  @behaviour Bodyguard.Policy

  alias Guilda.Accounts.User

  def authorize(:create_transaction, %User{is_admin: true}, _params), do: true

  def authorize(:update_transaction, %User{is_admin: true}, _params), do: true

  def authorize(:delete_transaction, %User{is_admin: true}, _params), do: true

  def authorize(_action, _user, _params),
    do: {:error, Err.wrap(mod: GuildaWeb.UserAuth, reason: :unauthorized)}
end
