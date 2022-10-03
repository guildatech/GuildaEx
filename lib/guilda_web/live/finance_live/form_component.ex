defmodule GuildaWeb.FinanceLive.FormComponent do
  @moduledoc """
  LiveView Component to display a form for a transaction.
  """
  use GuildaWeb, :live_component

  alias Guilda.Finances

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Finances.change_transaction(transaction) |> set_transaction_type()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Finances.change_transaction(toggle_amount_signal(transaction_params))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Finances.update_transaction(
           socket.assigns.current_user,
           socket.assigns.transaction,
           toggle_amount_signal(transaction_params)
         ) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, Err.message(error))
         |> push_redirect(to: Routes.finance_index_path(socket, :index))}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    case Finances.create_transaction(socket.assigns.current_user, toggle_amount_signal(transaction_params)) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully.")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, Err.message(error))
         |> push_redirect(to: Routes.finance_index_path(socket, :index))}
    end
  end

  defp set_transaction_type(changeset) do
    negative_amount = Decimal.lt?(Ecto.Changeset.get_field(changeset, :amount), 0)

    if negative_amount do
      Ecto.Changeset.put_change(changeset, :transaction_type, :outflow)
    else
      Ecto.Changeset.put_change(changeset, :transaction_type, :inflow)
    end
  end

  defp toggle_amount_signal(attrs) do
    type = Map.get(attrs, "transaction_type")

    Map.update(attrs, "amount", "", fn
      "" when type == "inflow" ->
        "0.00"

      "" ->
        "-0.00"

      value when type == "inflow" ->
        String.replace(value, "-", "")

      value ->
        value = String.replace(value, "-", "")
        "-#{value}"
    end)
  end
end
