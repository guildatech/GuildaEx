defmodule GuildaWeb.PageLiveTest do
  use GuildaWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "index" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/")
      assert disconnected_html =~ "Boas vindas à"
      assert render(page_live) =~ "Boas vindas à"
    end
  end
end
