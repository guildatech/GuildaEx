defmodule GuildaWeb.FinanceLive.TransactionComponent do
  @moduledoc """
  LiveView Component to display a transaction.
  """
  use GuildaWeb, :live_component

  alias Guilda.Finances

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
    <tr id="<% @id %>">
      <td class="Table__td"><%= @transaction.date %></td>
      <td class="Table__td"><%= @transaction.payee %></td>
      <td class="Table__td"><%= @transaction.note %></td>
      <td align="right" class="Table__td"><%= @transaction.amount %></td>
      <%= if Bodyguard.permit?(Finances, :manage_transaction, @current_user) do %>
        <td align="right" class="space-x-1 Table__td">
          <%= if Bodyguard.permit?(Finances, :update_transaction, @current_user), do: live_patch gettext("Editar"), to: Routes.finance_index_path(@socket, :edit, @transaction), class: "TableAction--edit" %>
          <%= if Bodyguard.permit?(Finances, :delete_transaction, @current_user) do %>
            <button type="button" class="TableAction--delete" phx-click="delete" phx-target="<%= @myself %>" phx-value-id="<%= @transaction.id %>" data-confirm="<%= gettext("Tem certeza?") %>"><%= gettext("Excluir") %></button>
          <% end %>
        </td>
      <% end %>
    </tr>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Finances.get_transaction!(id)

    case Finances.delete_transaction(socket.assigns.current_user, transaction) do
      {:ok, _episode} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Transação excluída com sucesso."))
         |> push_redirect(to: Routes.finance_index_path(socket, :index))}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, Err.message(error))
         |> push_redirect(to: Routes.finance_index_path(socket, :index))}
    end
  end
end
