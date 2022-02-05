defmodule GuildaWeb.MembersLive do
  @moduledoc """
  LiveView to display a map with all recorded user's locations.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Guilda.PubSub, "member_location")
    end

    {:ok,
     assign(socket,
       markers: Accounts.list_users_locations(),
       bot_name: GuildaWeb.AuthController.telegram_bot_username()
     ), temporary_assigns: [markers: []]}
  end

  @impl true
  def handle_info({Accounts, %Accounts.Events.LocationAdded{} = update}, socket) do
    {:noreply, update(socket, :markers, fn markers -> [%{lat: update.lat, lng: update.lng} | markers] end)}
  end

  def handle_info({Accounts, _}, socket), do: {:noreply, socket}
end
