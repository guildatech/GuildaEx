defmodule GuildaWeb.FinanceLive.FormComponent do
  @moduledoc """
  LiveView Component to display a form for a transaction.
  """
  use GuildaWeb, :live_component

  alias Guilda.Finances

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset =
      Finances.change_transaction(transaction)
      |> set_toggle_value()

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
         |> put_flash(:info, "Transação atualizada com sucesso.")
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
         |> put_flash(:info, "Transação cadastrada com sucesso.")
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

  defp toggle_amount_signal(attrs) do
    toggle = Map.get(attrs, "toggle", "false")

    Map.update(attrs, "amount", "", fn
      "" when toggle == "true" ->
        "0.00"

      "" ->
        "-0.00"

      value when toggle == "true" ->
        String.replace(value, "-", "")

      value ->
        value = String.replace(value, "-", "")
        "-#{value}"
    end)
  end

  defp set_toggle_value(changeset) do
    set_toggle_value(changeset, changeset.data)
  end

  defp set_toggle_value(changeset, %{amount: nil}), do: Ecto.Changeset.put_change(changeset, :amount, "-0.00")

  defp set_toggle_value(changeset, %{amount: amount}) do
    if Decimal.lt?(amount, 0) do
      changeset
    else
      Ecto.Changeset.put_change(changeset, :toggle, true)
    end
  end
end
