defmodule GuildaWeb.MountHooks.TrackPresence do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  def on_mount(_any, _params, _session, socket) do
    if user = socket.assigns[:current_user] do
      GuildaWeb.Presence.track_user(user.id)
    end

    {:cont, socket}
  end
end
