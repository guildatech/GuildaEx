defmodule GuildaWeb.PodcastEpisodeLive.Index do
  @moduledoc """
  LiveView Component to list podcast episodes.
  """
  use GuildaWeb, :live_view

  alias Guilda.Podcasts
  alias Guilda.Podcasts.Episode

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, params, session)

    {:ok, assign(socket, podcast_episodes: list_podcast_episodes())}
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
    case Bodyguard.permit(Podcasts, :create_episode, socket.assigns.current_user) do
      :ok ->
        socket
        |> assign(:page_title, gettext("Novo episódio"))
        |> assign(:episode, %Episode{})

      {:error, error} ->
        socket
        |> put_flash(:error, Err.message(error))
        |> push_redirect(to: Routes.podcast_episode_index_path(socket, :index))
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case Bodyguard.permit(Podcasts, :update_episode, socket.assigns.current_user) do
      :ok ->
        socket
        |> assign(:page_title, gettext("Editar episódio"))
        |> assign(:episode, Podcasts.get_episode!(id))

      {:error, error} ->
        socket
        |> put_flash(:error, Err.message(error))
        |> push_redirect(to: Routes.podcast_episode_index_path(socket, :index))
    end
  end

  defp list_podcast_episodes do
    Podcasts.list_podcast_episodes()
  end
end
