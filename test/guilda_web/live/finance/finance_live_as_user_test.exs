defmodule GuildaWeb.FinanceLiveAsUserTest do
  use GuildaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Guilda.FinancesFixtures

  setup :register_and_log_in_user

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
    test "disconnected and connected render", %{conn: conn} = opts do
      {:ok, view, disconnected_html} = live(conn, path(:index, opts))
      assert disconnected_html =~ "Finanças"
      assert render(view) =~ "Finanças"
      assert disconnected_html =~ "Beneficiário"
      assert render(view) =~ "Beneficiário"
    end

    test "does not display a button to add a new transaction", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      refute view |> element("a[href='#{path(:new, opts)}']") |> has_element?()
    end
  end

  describe "index with transactions" do
    setup :create_transaction

    test "displays the transactions", %{conn: conn, transaction: transaction} = opts do
      {:ok, _view, html} = live(conn, path(:index, opts))
      assert html =~ transaction.payee
    end

    test "does not display a button to edit the transaction", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      refute view |> element("a[href='#{path(:edit, transaction, opts)}']") |> has_element?()
    end

    test "does not display a button to delete the transaction", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      refute view |> element("button[phx-click=delete][phx-value-id='#{transaction.id}']") |> has_element?()
    end
  end

  describe "adding a new transaction" do
    test "redirects", %{conn: conn} = opts do
      finances_index = path(:index, opts)
      assert {:error, {:live_redirect, %{to: ^finances_index}}} = live(conn, path(:new, opts))
    end
  end

  describe "editting a transaction" do
    setup :create_transaction

    test "redirects", %{conn: conn, transaction: transaction} = opts do
      finances_index = path(:index, opts)
      assert {:error, {:live_redirect, %{to: ^finances_index}}} = live(conn, path(:edit, transaction, opts))
    end
  end
end
