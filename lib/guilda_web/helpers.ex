defmodule GuildaWeb.Helpers do
  @moduledoc """
  General helpers used through the app.
  """
  use Phoenix.Component
  import GuildaWeb.Gettext
  import GuildaWeb.Components.Button
  alias Phoenix.LiveView.JS

  def table(assigns) do
    extra = assigns_to_attributes(assigns, [:class, :empty_state, :id, :row_id, :tbody_extra, :col, :rows])

    assigns =
      assigns
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:empty_state, fn -> gettext("No records to show.") end)
      |> assign_new(:id, fn -> false end)
      |> assign_new(:row_id, fn -> false end)
      |> assign_new(:tbody_extra, fn -> [] end)
      |> assign(:col, for(col <- assigns.col, col[:if] != false, do: col))
      |> assign(:extra, extra)

    ~H"""
    <table class={"Table #{@class}"}>
      <thead>
        <tr>
          <%= for col <- @col do %>
            <th class="Table__th" {column_extra_attributes(col)}><%= col.label %></th>
          <% end %>
        </tr>
      </thead>
      <tbody id={@id} class="Table__body" {@tbody_extra}>
        <%= if @rows == [] do %>
          <tr id={"#{@id}-empty-state"}>
            <td colspan={Kernel.length(@col)} class="Table__td"><%= @empty_state %></td>
          </tr>
        <% end %>
        <%= for row <- @rows do %>
          <tr id={@row_id && @row_id.(row)}>
            <%= for col <- @col do %>
              <td class={"Table__td #{Map.get(col, :class)}"} {column_extra_attributes(col)}><%= render_slot(col, row) %></td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  defp column_extra_attributes(col) do
    assigns_to_attributes(col, [:if, :class, :label])
  end

  @doc """
  Renders [Remix](https://remixicon.com) icon.

  ## Examples

      <.remix_icon icon="cpu-line" />

      <.remix_icon icon="cpu-line" class="mr-1 align-middle" />
  """
  def remix_icon(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign(:attrs, assigns_to_attributes(assigns, [:icon, :class]))

    ~H"""
    <i class={"ri-#{@icon} #{@class}"} aria-hidden="true" {@attrs}></i>
    """
  end
end
