defmodule GuildaWeb.Live.LiveHelpers do
  @moduledoc """
  Helpers used by LiveViews.
  """
  import Phoenix.LiveView, only: [assign: 2, assign_new: 3]

  alias Guilda.Accounts

  @doc """
  Assign default values on the socket.
  """
  def assign_defaults(socket, params \\ %{}, session \\ %{})

  def assign_defaults(socket, _params, session) do
    socket
    |> assign_menu()
    |> assign_default(:current_user, session)
  end

  defp assign_menu(socket) do
    assign(socket, menu: %{action: socket.assigns.live_action, module: socket.view})
  end

  defp assign_default(socket, :current_user, %{"user_token" => user_token}) do
    socket
    |> assign_new(:user_token, fn -> user_token end)
    |> assign_new(:current_user, fn -> Accounts.get_user_by_session_token(user_token) end)
  end

  defp assign_default(socket, :current_user, _) do
    assign(socket, current_user: nil)
  end
end
