defmodule GuildaWeb.PodcastEpisodeLive.EpisodeComponent do
  @moduledoc """
  LiveView Component to display a podcast episode.
  """
  use GuildaWeb, :live_component

  alias Guilda.Podcasts

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, seconds_played: 0, viewed: false)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col overflow-hidden rounded-lg shadow-lg">
      <div class="flex-shrink-0">
        <img
          class="object-cover w-full h-50"
          src={@episode.cover_url}
          alt={gettext("%{episode_name} episode cover", episode_name: @episode.title)}
        />
      </div>
      <div class="flex flex-col justify-between flex-1 p-6 bg-white">
        <div class="flex-1">
          <a href="#" class="block mt-2">
            <p class="text-xl font-semibold text-gray-900">
              <%= @episode.title %>
            </p>
            <p class="mt-3 text-base text-gray-500">
              <%= @episode.description %>
            </p>
          </a>
        </div>
        <div class="flex flex-col mt-6">
          <p class="text-sm text-gray-900">
            <%= @episode.hosts %>
          </p>
          <div class="flex space-x-1 text-sm text-gray-500">
            <time datetime="2020-03-16">
              <%= GuildaWeb.ViewHelpers.format_date(@episode.aired_date) %>
            </time>
            <span aria-hidden="true">
              &middot;
            </span>
            <span>
              <%= GuildaWeb.ViewHelpers.format_seconds(@episode.length) %>
            </span>
          </div>
        </div>
      </div>
      <div>
        <div class="flex -mt-px bg-white border-t divide-x divide-gray-200 border-t-gray-200">
          <audio
            id={"player-#{@episode.id}"}
            class="w-full"
            src={@episode.file_url}
            type={@episode.file_type}
            phx-hook="PodcastPlayer"
            data-target={@id}
            data-episode-id={@episode.id}
            data-episode-slug={@episode.slug}
            controls
          >
          </audio>
        </div>
      </div>
      <div>
        <div class="flex -mt-px bg-white border-t divide-x divide-gray-200 border-t-gray-200">
          <%= if Bodyguard.permit?(Podcasts, :update_episode, @current_user) do %>
            <div class="flex flex-1 w-0">
              <%= live_patch(gettext("Edit"),
                to: Routes.podcast_episode_index_path(@socket, :edit, @episode),
                class:
                  "relative -mr-px w-0 flex-1 inline-flex items-center justify-center py-4 text-sm text-gray-700 font-medium border border-transparent rounded-bl-lg hover:text-gray-500"
              ) %>
            </div>
          <% end %>
          <%= if Bodyguard.permit?(Podcasts, :delete_episode, @current_user) do %>
            <div class="flex flex-1 w-0 -ml-px">
              <button
                type="button"
                phx-click="delete"
                phx-target={@myself}
                phx-value-id={@episode.id}
                data-confirm="Tem certeza?"
                class="relative inline-flex items-center justify-center flex-1 w-0 py-4 -mr-px text-sm font-medium text-gray-700 border border-transparent rounded-bl-lg hover:text-gray-500"
              >
                <%= gettext("Delete") %>
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete", %{"id" => id}, socket) do
    episode = Podcasts.get_episode!(id)

    case Podcasts.delete_episode(socket.assigns.current_user, episode) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Episode deleted successfully."))
         |> push_redirect(to: Routes.podcast_episode_index_path(socket, :index))}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, Err.message(error))
         |> push_redirect(to: Routes.podcast_episode_index_path(socket, :index))}
    end
  end

  def handle_event("play-second-elapsed", %{"time" => _time}, %{assigns: %{episode: episode, viewed: false}} = socket) do
    seconds_played = socket.assigns.seconds_played + 1

    socket =
      if Podcasts.should_mark_as_viewed?(episode, seconds_played) do
        Podcasts.increase_play_count(episode)

        socket
        |> assign(viewed: true)
        |> push_event("episode-viewed", %{id: episode.id, slug: episode.slug})
      else
        assign(socket, seconds_played: seconds_played)
      end

    {:noreply, socket}
  end

  def handle_event("play-second-elapsed", %{"time" => _time}, socket) do
    {:noreply, socket}
  end
end
