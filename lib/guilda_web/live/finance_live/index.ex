defmodule GuildaWeb.FinanceLive.Index do
  @moduledoc """
  LiveView Component to list transactions.
  """
  use GuildaWeb, :live_view

  alias Guilda.Finances
  alias Guilda.Finances.Transaction

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, params, session)

    if connected?(socket), do: Finances.subscribe()

    {:ok, assign(socket, :transactions, fetch_transactions()), temporary_assigns: [transactions: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Editar Transação"))
    |> assign(:transaction, Finances.get_transaction!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("Nova Transação"))
    |> assign(:transaction, %Transaction{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Finanças"))
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Finances.get_transaction!(id)
    {:ok, _} = Finances.delete_transaction(transaction)

    {:noreply, assign(socket, :transactions, fetch_transactions())}
  end

  @impl true
  def handle_info({:transaction_created, transaction}, socket) do
    {:noreply, update(socket, :transactions, fn transactions -> [transaction | transactions] end)}
  end

  def handle_info({:transaction_updated, transaction}, socket) do
    {:noreply, update(socket, :transactions, fn transactions -> [transaction | transactions] end)}
  end

  defp fetch_transactions do
    Finances.list_transactions()
  end
end
