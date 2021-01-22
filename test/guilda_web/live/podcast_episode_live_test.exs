defmodule GuildaWeb.PodcastEpisodeLiveTest do
  use GuildaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Guilda.Podcasts

  @valid_attrs %{cover: "some cover", path: "some path", length: 42, play_count: 42, tags: []}

  defp fixture(:episode) do
    {:ok, episode} = Podcasts.create_episode(@valid_attrs)
    episode
  end

  defp create_episode(_) do
    episode = fixture(:episode)
    %{episode: episode}
  end

  describe "index" do
    setup [:create_episode]

    test "list all podcast episodes", %{conn: conn, episode: episode} do
      {:ok, _live, html} = live(conn, Routes.podcast_episode_index_path(conn, :index))

      assert html =~ "Lista de episódios"
      assert html =~ episode.cover
    end

    test "displays a button to add a new episode", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.podcast_episode_index_path(conn, :index))

      assert view |> element("a[href='/podcasts/new']") |> has_element?()
    end
  end

  describe "adding a new episode" do
    test "displays the form", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.podcast_episode_index_path(conn, :new))
      assert view |> element("form[id=episode-form]") |> has_element?
      assert view |> element("input[name='episode[cover]']") |> has_element?
    end

    test "saves and redirects with valid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.podcast_episode_index_path(conn, :new))

      {:ok, _view, html} =
        view
        |> form("form[phx-submit=save")
        |> render_submit(%{
          "episode" => %{
            "cover" => "a new episode",
            "path" => "some episode"
          }
        })
        |> follow_redirect(conn)

      assert html =~ "a new episode"
    end

    test "displays errors when submitting invalid values", %{conn: conn} do
      {:ok, view, html} = live(conn, Routes.podcast_episode_index_path(conn, :new))

      refute html =~ "can&apos;t be blank"
      assert view |> form("form[phx-submit=save") |> render_submit() =~ "can&apos;t be blank"
    end
  end
end
