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
      <td align="right" class="Table__td">
        <%= live_patch gettext("Editar"), to: Routes.finance_index_path(@socket, :edit, @transaction) %> | <button type="button" phx-click="delete" phx-target="<%= @myself %>" phx-value-id="<%= @transaction.id %>" data-confirm="Tem certeza?"><%= gettext("Excluir") %></button>
      </td>
    </tr>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Finances.get_transaction!(id)
    {:ok, _} = Finances.delete_transaction(transaction)

    {:noreply, push_redirect(socket, to: Routes.finance_index_path(socket, :index))}
  end
end
