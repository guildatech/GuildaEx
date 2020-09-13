defmodule GuildaWeb.FinanceLive.TransactionComponent do
  use GuildaWeb, :live_component

  def render(assigns) do
    ~L"""
    <tr>
      <td class="Table__td"><%= @transaction.inserted_at %></td>
      <td class="Table__td"><%= @transaction.payee %></td>
      <td class="Table__td"><%= @transaction.note %></td>
      <td align="right" class="Table__td"><%= @transaction.amount %></td>
    </tr>
    """
  end
end
