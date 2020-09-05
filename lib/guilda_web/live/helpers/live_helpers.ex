defmodule GuildaWeb.Live.LiveHelpers do
  import Phoenix.LiveView, only: [assign: 2]

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
    assign(socket, menu: %{action: socket.assigns.live_action, module: socket.assigns.live_module})
  end

  defp assign_default(socket, :current_user, %{"user_token" => user_token}) do
    user = Accounts.get_user_by_session_token(user_token)
    assign(socket, current_user: user)
  end

  defp assign_default(socket, :current_user, _) do
    assign(socket, current_user: nil)
  end
end
