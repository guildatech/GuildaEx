defmodule GuildaWeb.Live.LiveHelpers do
  @moduledoc """
  Helpers used by LiveViews.
  """
  import Phoenix.LiveView, only: [assign: 2]
  import Phoenix.LiveView.Helpers

  alias Guilda.Accounts

  @doc """
  Renders a component inside the `GuildaWeb.ModalComponent` component.
  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.
  ## Examples
      <%= live_modal @socket, GuildaWeb.PostLive.FormComponent,
        id: @post.id || :new,
        action: @live_action,
        post: @post,
        return_to: Routes.post_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    title = Keyword.fetch!(opts, :title)
    modal_opts = [id: :modal, return_to: path, title: title, component: component, opts: opts]
    live_component(socket, GuildaWeb.ModalComponent, modal_opts)
  end

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
    user = Accounts.get_user_by_session_token(user_token)
    assign(socket, current_user: user)
  end

  defp assign_default(socket, :current_user, _) do
    assign(socket, current_user: nil)
  end
end
