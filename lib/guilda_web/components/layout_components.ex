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

  def user_coordinates(assigns) do
    {lng, lat} = assigns.coordinates

    assigns =
      assigns
      |> assign(:lat, lat)
      |> assign(:lng, lng)

    ~H"""
    <leaflet-map lat={@lat} lng={@lng}>
      <leaflet-marker lat={@lat} lng={@lng} />
    </leaflet-map>
    """
  end

  def button(assigns) do
    assigns =
      assigns
      |> assign_new(:variant, fn -> "default" end)

    extra = assigns_to_attributes(assigns, [:text])

    assigns = Phoenix.LiveView.assign(assigns, :extra, extra)

    ~H"""
    <button type="button" class={button_classes(@variant)} {@extra}>
      <%= @text %>
    </button>
    """
  end

  def outline_button(assigns) do
    assigns =
      assigns
      |> assign_new(:variant, fn -> "default" end)

    extra = assigns_to_attributes(assigns, [:text, :icon, :variant])

    assigns = Phoenix.LiveView.assign(assigns, :extra, extra)

    ~H"""
    <button type="button" class={outline_button_classes(@variant)} {@extra}>
      <%= @text %>
    </button>
    """
  end

  defp button_classes("default") do
    variant_classes = "bg-white text-gray-700 border-gray-300 hover:bg-gray-50 focus:ring-blue-500"
    default_button_classes() <> " " <> variant_classes
  end

  defp outline_button_classes("danger") do
    variant_classes = "bg-white text-red-700 border-red-300 hover:bg-red-50 focus:ring-red-500"
    default_button_classes() <> " " <> variant_classes
  end

  defp default_button_classes do
    "inline-flex items-center px-3 py-2 text-sm font-medium leading-4 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end
end
