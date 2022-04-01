defmodule GuildaWeb.PodcastEpisodeAsUserLiveTest do
  use GuildaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Guilda.PodcastsFixtures

  setup :register_and_log_in_user

  defp create_episode(_) do
    %{episode: insert(:episode)}
  end

  defp path(:index, assigns) do
    Routes.podcast_episode_index_path(assigns.conn, :index)
  end

  defp path(:new, assigns) do
    Routes.podcast_episode_index_path(assigns.conn, :new)
  end

  defp path(:edit, episode, assigns) do
    Routes.podcast_episode_index_path(assigns.conn, :edit, episode)
  end

  describe "index" do
    setup :create_episode

    test "list all podcast episodes", %{conn: conn, episode: episode} = opts do
      {:ok, view, html} = live(conn, path(:index, opts))

      assert has_element?(view, "h2", "Quem Programa?, Guilda's podcast")
      assert html =~ episode.title
    end

    test "does not display a button to add a new episode", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      refute has_element?(view, "a[href='#{path(:new, opts)}']")
    end

    test "does not display a button to edit the episode", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      refute has_element?(view, "a[href='#{path(:edit, episode, opts)}']")
    end

    test "does not display a button to delete the episode", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      refute has_element?(view, "button[phx-click=delete][phx-value-id='#{episode.id}']")
    end
  end

  describe "adding a new episode" do
    test "redirects", %{conn: conn} = opts do
      podcast_index = path(:index, opts)
      assert {:error, {:live_redirect, %{to: ^podcast_index}}} = live(conn, path(:new, opts))
    end
  end

  describe "editting an episode" do
    setup :create_episode

    test "redirects", %{conn: conn} = opts do
      podcast_index = path(:index, opts)
      assert {:error, {:live_redirect, %{to: ^podcast_index}}} = live(conn, path(:new, opts))
    end
  end
end
