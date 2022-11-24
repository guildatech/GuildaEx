defmodule GuildaWeb.HomeLive do
  @moduledoc """
  LiveView to generate static pages.
  """
  use GuildaWeb, {:live_view, container: {:div, class: "flex flex-col flex-grow"}}
  alias Guilda.Podcasts

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, gettext("Home"))
      |> assign(:featured_episode, Podcasts.most_recent_episode())

    {:ok, socket}
  end
end
