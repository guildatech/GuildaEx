defmodule GuildaWeb.PodcastEpisodeLive.Index do
  use GuildaWeb, :live_view

  alias Guilda.Podcasts
  alias Guilda.Podcasts.Episode

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, params, session)

    {:ok, assign(socket, :podcast_episodes, list_podcast_episodes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Quem Programa?")
    |> assign(:episode, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("Novo episódio"))
    |> assign(:episode, %Episode{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Editar episódio"))
    |> assign(:episode, Podcasts.get_episode!(id))
  end

  defp list_podcast_episodes do
    Podcasts.list_podcast_episodes()
  end
end
