defmodule GuildaWeb.MountHooks.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.Component, only: [assign: 2, assign_new: 3]
  alias Guilda.Accounts
  alias GuildaWeb.RequestContext

  def on_mount(_any, _params, session, socket) do
    socket =
      socket
      |> assign_menu()
      |> assign_user(session)
      |> RequestContext.put_audit_context()

    {:cont, socket}
  end

  defp assign_menu(socket) do
    assign(socket, menu: %{action: socket.assigns.live_action, module: socket.view})
  end

  defp assign_user(socket, %{"user_token" => user_token}) do
    socket
    |> assign_new(:user_token, fn -> user_token end)
    |> assign_new(:current_user, fn -> Accounts.get_user_by_session_token(user_token) end)
  end

  defp assign_user(socket, _) do
    assign(socket, current_user: nil)
  end
end
