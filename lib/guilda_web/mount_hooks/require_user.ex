defmodule GuildaWeb.MountHooks.RequireUser do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import GuildaWeb.Gettext

  alias GuildaWeb.Router.Helpers, as: Routes

  def on_mount(_any, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      socket =
        socket
        |> put_flash(:error, gettext("You must be signed in to access this page."))
        |> redirect(to: Routes.user_session_path(socket, :new))

      {:halt, socket}
    end
  end
end
