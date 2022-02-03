defmodule GuildaWeb.MembersLive do
  @moduledoc """
  LiveView to display a map with all recorded user's locations.
  """
  use GuildaWeb, :live_view

  alias Guilda.Accounts

  @impl true
  def mount(_params, _session, socket) do
    locations = Accounts.list_users_locations()
    [lat, lng] = Geocalc.geographic_center(locations)
    {:ok, assign(socket, markers: locations, center_lat: lat, center_lng: lng)}
  end
end
