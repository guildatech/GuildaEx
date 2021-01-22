defmodule GuildaWeb.PodcastEpisodeLive.EpisodeComponent do
  use GuildaWeb, :live_component

  alias Guilda.Podcasts

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
    <tr id="<% @id %>">
      <td class="Table__td"><%= @episode.cover %></td>
      <td class="Table__td"><%= @episode.path %></td>
      <td align="right" class="Table__td"><%= @episode.length %></td>
      <td align="right" class="Table__td">
        <%= live_patch gettext("Editar"), to: Routes.podcast_episode_index_path(@socket, :edit, @episode) %> | <button type="button" phx-click="delete" phx-target="<%= @myself %>" phx-value-id="<%= @episode.id %>" data-confirm="Tem certeza?"><%= gettext("Excluir") %></button>
      </td>
    </tr>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete", %{"id" => id}, socket) do
    episode = Podcasts.get_episode!(id)
    {:ok, _} = Podcasts.delete_episode(episode)

    {:noreply, push_redirect(socket, to: Routes.podcast_episode_index_path(socket, :index))}
  end
end
