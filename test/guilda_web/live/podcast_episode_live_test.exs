defmodule GuildaWeb.PodcastEpisodeLiveTest do
  use GuildaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Guilda.PodcastsFixtures

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
      {:ok, _live, html} = live(conn, path(:index, opts))

      assert html =~ "Lista de episódios"
      assert html =~ episode.title
    end

    test "displays a button to add a new episode", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      assert has_element?(view, "a[href='#{path(:new, opts)}']")
    end

    test "displays a button to edit the episode", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      assert has_element?(view, "a[href='#{path(:edit, episode, opts)}']")
    end

    test "displays a button to delete the episode", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      assert has_element?(view, "button[phx-click=delete][phx-value-id='#{episode.id}']")
    end
  end

  describe "adding a new episode" do
    test "disconnected and connected render", %{conn: conn} = opts do
      {:ok, view, html} = live(conn, path(:new, opts))
      assert html =~ "Novo episódio"
      assert render(view) =~ "Novo episódio"
    end

    test "displays the form", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.podcast_episode_index_path(conn, :new))
      assert has_element?(view, "form[id=episode-form]")
      assert has_element?(view, "input[name='episode[title]']")
    end

    test "saves and redirects with valid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.podcast_episode_index_path(conn, :new))

      {:ok, _view, html} =
        view
        |> form("form[phx-submit=save")
        |> render_submit(%{
          "episode" => %{
            "title" => "a new episode",
            "slug" => "some episode",
            "cover_url" => "some episode",
            "cover_name" => "some episode",
            "cover_type" => "some episode",
            "cover_size" => "42",
            "file_url" => "some episode",
            "file_name" => "some episode",
            "file_type" => "some episode",
            "file_size" => "42"
          }
        })
        |> follow_redirect(conn)

      assert html =~ "a new episode"
    end

    test "displays a link to return to the episodes list", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:new, opts))

      assert has_element?(view, "a[href='#{path(:index, opts)}']", "Cancelar")
    end

    test "displays errors when submitting invalid values", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.podcast_episode_index_path(conn, :new))

      refute has_element?(view, "#episode-form", "can't be blank")
      view |> form("form[phx-submit=save]", %{"episode" => %{"title" => ""}}) |> render_submit()
      assert has_element?(view, "#episode-form", "can't be blank")
    end
  end

  describe "editting an episode" do
    setup :create_episode

    test "disconnected and connected render", %{conn: conn, episode: episode} = opts do
      {:ok, view, html} = live(conn, path(:edit, episode, opts))
      assert html =~ "Editar episódio"
      assert render(view) =~ "Editar episódio"
    end

    test "displays a form", %{conn: conn, episode: episode} = opts do
      {:ok, view, html} = live(conn, path(:edit, episode, opts))
      assert html =~ episode.title
      assert html =~ episode.slug
      assert has_element?(view, "form[id=episode-form]")
      assert has_element?(view, "input[name='episode[title]']")
    end

    test "displays a link to return to the episodes list", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:edit, episode, opts))

      assert has_element?(view, "a[href='#{path(:index, opts)}']", "Cancelar")
    end

    test "displays erros when submitting invalid values", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:edit, episode, opts))

      refute has_element?(view, "#episode-form", "can't be blank")
      view |> form("form[phx-submit=save]", %{"episode" => %{"title" => ""}}) |> render_submit()
      assert has_element?(view, "#episode-form", "can't be blank")
    end

    test "redirects when submitting valid values", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:edit, episode, opts))

      {:ok, _view, html} =
        view
        |> form("form[phx-submit=save]")
        |> render_submit(%{
          "episode" => %{
            "title" => "some updated episode"
          }
        })
        |> follow_redirect(conn)

      assert html =~ "some updated episode"
    end
  end

  describe "deleting an episode" do
    setup :create_episode

    test "removes the episode and redirects", %{conn: conn, episode: episode} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))

      assert render(view) =~ episode.title

      {:ok, view, _html} =
        view
        |> element("button[phx-click=delete][phx-value-id='#{episode.id}']")
        |> render_click()
        |> follow_redirect(conn, path(:index, opts))

      refute render(view) =~ episode.title
    end
  end
end
