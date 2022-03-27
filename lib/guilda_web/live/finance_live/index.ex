defmodule GuildaWeb.FinanceLive.Index do
  @moduledoc """
  LiveView Component to list transactions.
  """
  use GuildaWeb, :live_view

  alias Guilda.Finances
  alias Guilda.Finances.Transaction

  on_mount GuildaWeb.MountHooks.RequireUser

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Finances.subscribe()

    {:ok, fetch_transactions(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case Bodyguard.permit(Finances, :update_transaction, socket.assigns.current_user) do
      :ok ->
        socket
        |> assign(:page_title, gettext("Edit Transaction"))
        |> assign(:transaction, Finances.get_transaction!(id))

      {:error, error} ->
        socket
        |> put_flash(:error, Err.message(error))
        |> push_patch(to: Routes.finance_index_path(socket, :index))
    end
  end

  defp apply_action(socket, :new, _params) do
    case Bodyguard.permit(Finances, :create_transaction, socket.assigns.current_user) do
      :ok ->
        socket
        |> assign(:page_title, gettext("New Transaction"))
        |> assign(:transaction, %Transaction{})

      {:error, error} ->
        socket
        |> put_flash(:error, Err.message(error))
        |> push_patch(to: Routes.finance_index_path(socket, :index))
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Finances"))
    |> assign(:transaction, nil)
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Finances.get_transaction!(id)

    case Finances.delete_transaction(socket.assigns.current_user, transaction) do
      {:ok, _episode} ->
        {:noreply, put_flash(socket, :info, gettext("Transaction removed successfully."))}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, Err.message(error))
         |> push_patch(to: Routes.finance_index_path(socket, :index))}
    end
  end

  @impl true
  def handle_info({:transaction_created, _transaction}, socket) do
    {:noreply, fetch_transactions(socket)}
  end

  def handle_info({:transaction_updated, _transaction}, socket) do
    {:noreply, fetch_transactions(socket)}
  end

  def handle_info({:transaction_deleted, _transaction}, socket) do
    {:noreply, fetch_transactions(socket)}
  end

  defp fetch_transactions(socket) do
    assign(socket, :transactions, Finances.list_transactions())
  end
end
