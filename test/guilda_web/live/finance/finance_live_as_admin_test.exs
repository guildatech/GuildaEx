defmodule GuildaWeb.FinanceLiveAsAdminTest do
  use GuildaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import Guilda.FinancesFixtures

  setup :register_and_log_in_admin_user

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

    test "displays a button to add a new transaction", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      assert view |> element("a[href='#{path(:new, opts)}']") |> has_element?()
    end
  end

  describe "index with transactions" do
    setup :create_transaction

    test "displays the transactions", %{conn: conn, transaction: transaction} = opts do
      {:ok, _view, html} = live(conn, path(:index, opts))
      assert html =~ transaction.payee
    end

    test "displays a button to edit the transaction", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      assert view |> element("a[href='#{path(:edit, transaction, opts)}']") |> has_element?()
    end

    test "displays a button to delete the transaction", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))
      assert view |> element("button[id='delete-transaction-#{transaction.id}']") |> has_element?()
    end
  end

  describe "adding a new transaction" do
    test "disconnected and connected render", %{conn: conn} = opts do
      {:ok, page_live, disconnected_html} = live(conn, path(:new, opts))
      assert disconnected_html =~ "Nova Transação"
      assert render(page_live) =~ "Nova Transação"
    end

    test "displays the form", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:new, opts))
      assert view |> element("form[id=transaction-form") |> has_element?
      assert view |> element("input[name='transaction[amount]']") |> has_element?
    end

    test "saves and redirects with valid data", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:new, opts))

      {:ok, _view, html} =
        view
        |> form("form[phx-submit=save]", %{
          "transaction" => %{
            "amount" => "10",
            "date" => "2020-02-02",
            "payee" => "a new payee"
          }
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "a new payee"
    end

    test "displays a link to return to the transactions list", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:new, opts))

      assert view
             |> element("a[href='#{path(:index, opts)}']")
             |> has_element?
    end

    test "displays erros when submitting invalid values", %{conn: conn} = opts do
      {:ok, view, _html} = live(conn, path(:new, opts))

      refute has_element?(view, "form[phx-submit=save]", "can't be blank")
      view |> form("form[phx-submit=save]") |> render_submit()
      assert has_element?(view, "form[phx-submit=save]", "can't be blank")
    end
  end

  describe "editting a transaction" do
    setup :create_transaction

    test "disconnected and connected render", %{conn: conn, transaction: transaction} = opts do
      {:ok, page_live, disconnected_html} = live(conn, path(:edit, transaction, opts))
      assert disconnected_html =~ "Editar Transação"
      assert render(page_live) =~ "Editar Transação"
    end

    test "displays a form", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, html} = live(conn, path(:edit, transaction, opts))
      assert html =~ transaction.payee
      assert html =~ transaction.note
      assert view |> element("form[id=transaction-form") |> has_element?
      assert view |> element("input[name='transaction[amount]']") |> has_element?
    end

    test "displays a link to return to the transactions list", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:edit, transaction, opts))

      assert view
             |> element("a[href='#{path(:index, opts)}']")
             |> has_element?
    end

    test "displays erros when submitting invalid values", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:edit, transaction, opts))

      refute has_element?(view, "form[phx-submit=save]", "can't be blank")

      view
      |> form("form[phx-submit=save]", %{"transaction" => %{"date" => ""}})
      |> render_submit()

      assert has_element?(view, "form[phx-submit=save]", "can't be blank")
    end

    test "redirects when submitting valid values", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:edit, transaction, opts))

      {:ok, _view, html} =
        view
        |> form("form[phx-submit=save]", %{
          "transaction" => %{
            "payee" => "some updated transaction"
          }
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "some updated transaction"
    end
  end

  describe "deleting a transaction" do
    setup :create_transaction

    test "removes the record from the page", %{conn: conn, transaction: transaction} = opts do
      {:ok, view, _html} = live(conn, path(:index, opts))

      assert has_element?(view, "td", transaction.note)

      render_click(element(view, "button[id='delete-modal-#{transaction.id}-confirm']"))

      refute has_element?(view, "td", transaction.note)
    end
  end
end
