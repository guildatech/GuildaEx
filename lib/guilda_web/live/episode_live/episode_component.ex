defmodule GuildaWeb.PodcastEpisodeLive.EpisodeComponent do
  use GuildaWeb, :live_component

  alias Guilda.Podcasts

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="flex flex-col overflow-hidden rounded-lg shadow-lg">
      <div class="flex-shrink-0">
        <img class="object-cover w-full h-50" src="<%= @episode.cover_url %>" alt="<%= gettext("Capa do episódio %{episode_name}", episode_name: @episode.title) %>">
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
              <%= format_date @episode.aired_date %>
            </time>
            <span aria-hidden="true">
              &middot;
            </span>
            <span>
              <%= format_seconds @episode.length %>
            </span>
          </div>
        </div>
      </div>
      <div>
        <div class="flex -mt-px bg-white border-t divide-x divide-gray-200 border-t-gray-200">
          <div class="flex flex-1 w-0">
            <%= live_patch gettext("Editar"), to: Routes.podcast_episode_index_path(@socket, :edit, @episode), class: "relative -mr-px w-0 flex-1 inline-flex items-center justify-center py-4 text-sm text-gray-700 font-medium border border-transparent rounded-bl-lg hover:text-gray-500" %>
          </div>
          <div class="flex flex-1 w-0 -ml-px">
            <button type="button" phx-click="delete" phx-target="<%= @myself %>" phx-value-id="<%= @episode.id %>" data-confirm="Tem certeza?" class="relative inline-flex items-center justify-center flex-1 w-0 py-4 -mr-px text-sm font-medium text-gray-700 border border-transparent rounded-bl-lg hover:text-gray-500"><%= gettext("Excluir") %></button>
          </div>
        </div>
      </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete", %{"id" => id}, socket) do
    episode = Podcasts.get_episode!(id)
    {:ok, _} = Podcasts.delete_episode(episode)

    {:noreply, push_redirect(socket, to: Routes.podcast_episode_index_path(socket, :index))}
  end

  # View Helpers
  def format_seconds(seconds) do
    seconds |> Timex.Duration.from_seconds() |> Timex.Duration.to_time!()
  end
end
