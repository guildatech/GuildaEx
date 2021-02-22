defmodule GuildaWeb.PageLive do
  @moduledoc """
  LiveView to generate static pages.
  """
  use GuildaWeb, {:live_view, container: {:div, class: "flex flex-col flex-grow"}}

  @impl true
  def mount(params, session, socket) do
    socket =
      socket
      |> assign_defaults(params, session)
      |> assign(:page_title, page_title(socket.assigns.live_action))

    {:ok, socket}
  end

  defp page_title(:index), do: "Home"
  defp page_title(_other), do: nil
end
