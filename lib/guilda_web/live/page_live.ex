defmodule GuildaWeb.PageLive do
  @moduledoc """
  LiveView to generate static pages.
  """
  use GuildaWeb, {:live_view, container: {:div, class: "flex flex-col flex-grow"}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:index), do: "Home"
  defp page_title(_other), do: nil
end
