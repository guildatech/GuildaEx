defmodule GuildaWeb.FinanceLiveAsGuestTest do
  use GuildaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Guilda.FinancesFixtures

  def create_transaction(_) do
    %{transaction: insert(:transaction)}
  end

  defp path(:index, assigns) do
    Routes.finance_index_path(assigns.conn, :index)
  end

  defp path(:new, assigns) do
    Routes.finance_index_path(assigns.conn, :new)
  end

  defp path(:edit, transaction, assigns) do
    Routes.finance_index_path(assigns.conn, :edit, transaction)
  end

  describe "index" do
    test "redirects", %{conn: conn} = opts do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, path(:index, opts))
    end
  end

  describe "adding a new transaction" do
    test "redirects", %{conn: conn} = opts do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, path(:new, opts))
    end
  end

  describe "editting a transaction" do
    setup :create_transaction

    test "redirects", %{conn: conn, transaction: transaction} = opts do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, path(:edit, transaction, opts))
    end
  end
end
