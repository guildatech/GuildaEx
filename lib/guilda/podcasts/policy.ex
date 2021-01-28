defmodule Guilda.Podcasts.Policy do
  @moduledoc """
  Authorization policy for the Podcasts context.
  """
  @behaviour Bodyguard.Policy

  alias Guilda.Accounts.User

  def authorize(:create_episode, %User{is_admin: true}, _params), do: true

  def authorize(:update_episode, %User{is_admin: true}, _params), do: true

  def authorize(:delete_episode, %User{is_admin: true}, _params), do: true

  def authorize(_action, _user, _params),
    do: {:error, Err.wrap(mod: GuildaWeb.UserAuth, reason: :unauthorized)}
end
