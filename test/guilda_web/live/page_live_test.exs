defmodule GuildaWeb.PageLiveTest do
  use GuildaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Guilda.PodcastsFixtures

  describe "index" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/")
      refute disconnected_html =~ "Listen to the new"
      assert disconnected_html =~ "Welcome to"
      assert render(page_live) =~ "Welcome to"
    end

    test "displays a link to podcasts if there are episodes", %{conn: conn} do
      insert(:episode)
      {:ok, _live, html} = live(conn, "/")
      assert html =~ "Listen to the new"
    end
  end
end
