defmodule GuildaWeb.OnlineMembersLive do
  @moduledoc """
  LiveView to display the count of online users.
  """
  use GuildaWeb,
      {:live_view,
       container: {:div, [class: "justify-end fixed inset-0 flex px-4 py-4 pointer-events-none sm:p-4 items-end"]}}

  on_mount GuildaWeb.MountHooks.InitAssigns

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if connected?(@socket) do %>
      <span class="inline-flex items-center px-3 py-0.5 rounded-full text-sm font-medium bg-green-100 text-green-800">
        <svg class="-ml-1 mr-1.5 h-2 w-2 text-green-400" fill="currentColor" viewBox="0 0 8 8">
          <circle cx="4" cy="4" r="3" />
        </svg>
        <%= @online_users_count %> <%= gettext("online") %>
      </span>
    <% else %>
      <span class="inline-flex items-center px-3 py-0.5 rounded-full text-sm font-medium bg-gray-100 text-gray-800">
        <svg class="-ml-1 mr-1.5 h-2 w-2 text-gray-400" fill="currentColor" viewBox="0 0 8 8">
          <circle cx="4" cy="4" r="3" />
        </svg>
        <%= gettext("Connecting") %>
      </span>
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    GuildaWeb.Presence.subscribe_to_online_users()

    if connected?(socket) do
      if user = socket.assigns[:current_user] do
        GuildaWeb.Presence.track_user(user.id)
      else
        if peer_data = get_connect_info(socket, :peer_data) do
          GuildaWeb.Presence.track_user(:inet.ntoa(peer_data.address))
        end
      end
    end

    {:ok, count_users(socket), layout: false}
  end

  @impl Phoenix.LiveView
  def handle_info({GuildaWeb.Presence, _users}, socket) do
    {:noreply, count_users(socket)}
  end

  defp count_users(socket) do
    users_count = GuildaWeb.Presence.list_users("online_users") |> Map.keys() |> Kernel.length()
    assign(socket, :online_users_count, users_count)
  end
end
