defmodule GuildaWeb.Components.LayoutComponents do
  use Phoenix.Component

  def main_content(assigns) do
    ~H"""
    <header class="pt-10">
      <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
        <h1 class="text-3xl font-bold leading-tight text-gray-900">
          <%= @title %>
        </h1>
      </div>
    </header>

    <!-- Main wrapper start -->
    <main class="px-4 py-6 mx-auto max-w-7xl sm:px-6 lg:px-8">

      <!-- Flash messages start -->
      <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="info"><%= live_flash(@flash, :info) %></p>
      <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="error"><%= live_flash(@flash, :error) %></p>
      <!-- Flash messages end -->

      <!-- Content grid start -->
      <div class="grid grid-cols-1 gap-5">
        <%= render_slot(@inner_block) %>
      </div>
      <!-- Content grid end -->

    </main>
    <!-- Main wrapper end -->
    """
  end

  def content_section(assigns) do
    assigns = assign_new(assigns, :subtitle, fn -> nil end)

    ~H"""
    <!-- Section start -->
      <div class="md:grid md:grid-cols-3 md:gap-6">

      <!-- Left column -->
      <div class="md:col-span-1">
        <h3 class="text-lg font-medium leading-6 text-gray-900"><%= @title %></h3>
        <%= if @subtitle do %>
          <p class="mt-1 text-sm leading-5 text-gray-600">
            <%= @subtitle %>
          </p>
        <% end %>
      </div>
      <!-- Left column end -->

      <!-- Right column -->
      <div class="mt-5 md:mt-0 md:col-span-2">
        <%= render_slot(@inner_block) %>
      </div>
      <!-- Right column end -->

    </div>
    <!-- Section end -->
    """
  end
end
