defmodule GuildaWeb.Podcasts.PodcastEpisodeLive.FormComponent do
  use GuildaWeb, :live_component

  alias Guilda.Podcasts

  @impl true
  def update(%{episode: episode} = assigns, socket) do
    changeset = Podcasts.change_episode(episode)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"episode" => episode_params}, socket) do
    save_episode(socket, socket.assigns.action, episode_params)
  end

  defp save_episode(socket, :new, episode_params) do
    case Podcasts.create_episode(episode_params) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, "Episódio salvo com sucesso.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
