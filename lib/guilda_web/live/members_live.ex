defmodule GuildaWeb.MembersLive do
  @moduledoc """
  LiveView to display a map with all recorded user's locations.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, markers: Accounts.list_users_locations(), bot_name: GuildaWeb.AuthController.telegram_bot_username())}
  end
end
