defmodule GuildaWeb.Components.LayoutComponents do
  @moduledoc """
  General phoenix component used through the app.
  """
  use Phoenix.Component
  alias GuildaWeb.Router.Helpers, as: Routes

  def main_content(assigns) do
    assigns = assign_new(assigns, :header_action, fn -> [] end)

    ~H"""
    <header class="pt-10">
      <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8 sm:flex sm:items-center sm:justify-between">
        <div class="flex-1 min-w-0">
        <h1 class="text-3xl font-bold leading-tight text-gray-900">
          <%= @title %>
        </h1>
        </div>
        <%= render_slot(@header_action) %>
      </div>
    </header>

    <!-- Main wrapper start -->
    <main class="px-4 py-6 mx-auto pb-36 max-w-7xl sm:px-6 lg:px-8">
      <!-- Content grid start -->
      <div class="grid grid-cols-1 gap-5">
        <%= render_slot(@inner_block) %>
      </div>
      <!-- Content grid end -->
    </main>
    <!-- Main wrapper end -->
    """
  end

  def guest_content(assigns) do
    ~H"""
    <!-- Main wrapper start -->
    <main class="flex flex-col justify-center h-full py-12 sm:px-6 lg:px-8">
      <!-- Content grid start -->
      <div class="flex flex-col justify-center min-h-full py-12 sm:px-6 lg:px-8">
        <div class="sm:mx-auto sm:w-full sm:max-w-md">
          <img class="w-auto h-24 mx-auto" src={Routes.static_path(GuildaWeb.Endpoint, "/images/guilda-logo.png")} alt="GuildaTech logo" />
          <h1 class="mt-6 text-3xl font-extrabold text-center text-gray-900"><%= @title %></h1>
        </div>
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

  def user_coordinates(assigns) do
    {lng, lat} = assigns.coordinates

    assigns =
      assigns
      |> assign(:lat, lat)
      |> assign(:lng, lng)

    ~H"""
    <div class="grid grid-cols-1 min-h-[180px]">
      <leaflet-map lat={@lat} lng={@lng} class="z-10">
        <leaflet-marker lat={@lat} lng={@lng} />
      </leaflet-map>
    </div>
    """
  end
end
