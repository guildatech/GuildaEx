# credo:disable-for-this-file Credo.Check.Readability.MaxLineLength
defmodule GuildaWeb.Components.Button do
  @moduledoc """
  HTML component to render buttons.
  """
  use Phoenix.Component
  import Phoenix.LiveView, only: [assign_new: 3]
  import GuildaWeb.Components.Link
  alias GuildaWeb.Components.Helpers

  def button(assigns) do
    assigns =
      assigns
      |> assign_new(:if, fn -> true end)
      |> assign_new(:link_type, fn -> "button" end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:icon, fn -> nil end)
      |> assign_new(:classes, fn -> button_classes(assigns) end)
      |> assign_new(:to, fn -> nil end)
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:extra_assigns, fn -> get_extra_assigns(assigns) end)
      |> assign_new(:size, fn -> "md" end)

    ~H"""
    <%= if @if do %>
      <.link to={@to} link_type={@link_type} class={@classes} disabled={@disabled} {@extra_assigns}>
        <%= render_icon(@icon, "-ml-0.5 mr-0.5 h-4 w-4") %>
        <%= if @inner_block do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <%= @label %>
        <% end %>
      </.link>
    <% end %>
    """
  end

  @doc false
  def button_classes(opts) do
    default = %{
      size: "md",
      variant: "solid",
      color: "primary",
      loading: false,
      disabled: false,
      icon: false,
      user_added_classes: opts[:class] || ""
    }

    opts = Map.merge(default, Map.take(opts, Map.keys(default)))

    """
      #{opts.user_added_classes}
      #{get_color_classes(opts)}
      #{size_css(opts.size)}
      #{loading_css(opts.loading)}
      #{get_disabled_classes(opts.disabled)}
      #{icon_css(opts.icon)}
      font-medium
      rounded-md
      inline-flex items-center justify-center
      border
      focus:outline-none
      transition duration-150 ease-in-out
    """
    |> Helpers.convert_string_to_one_line()
  end

  defp size_css(size) when is_binary(size) do
    case size do
      "xs" -> "text-xs leading-4 px-2.5 py-1.5"
      "sm" -> "text-sm leading-4 px-3 py-2"
      "md" -> "text-sm leading-5 px-4 py-2"
      "lg" -> "text-base leading-6 px-4 py-2"
      "xl" -> "text-base leading-6 px-6 py-3"
    end
  end

  defp loading_css(loading) do
    if loading, do: "flex gap-2 items-center whitespace-nowrap disabled cursor-not-allowed", else: ""
  end

  defp icon_css(icon) do
    if icon, do: "flex gap-2 items-center whitespace-nowrap", else: ""
  end

  defp get_extra_assigns(assigns) do
    assigns_to_attributes(assigns, [
      :if,
      :loading,
      :disabled,
      :link_type,
      :inner_block,
      :size,
      :variant,
      :color,
      :icon,
      :class,
      :to
    ])
  end

  defp get_color_classes(%{color: "primary", variant: variant}) do
    case variant do
      "outline" ->
        "border-primary-400 dark:border-primary-400 dark:hover:border-primary-300 dark:hover:text-primary-300 dark:hover:bg-transparent dark:text-primary-400 hover:border-primary-600 text-primary-600 hover:text-primary-700 active:bg-primary-200 hover:bg-primary-50 focus:border-primary-700 focus:shadow-outline-primary"

      _ ->
        "border-transparent text-primary-900 bg-primary-400 active:bg-primary-500 hover:bg-primary-300 focus:bg-primary-300 focus:shadow-outline-primary focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
    end
  end

  defp get_color_classes(%{color: "secondary", variant: variant}) do
    case variant do
      "outline" ->
        "border-secondary-400 dark:border-secondary-400 dark:hover:border-secondary-300 dark:hover:text-secondary-300 dark:hover:bg-transparent dark:text-secondary-400 hover:border-secondary-600 text-secondary-600 hover:text-secondary-700 active:bg-secondary-200 hover:bg-secondary-50 focus:border-secondary-700 focus:shadow-outline-secondary"

      _ ->
        "border-transparent text-white bg-secondary-600 active:bg-secondary-700 hover:bg-secondary-700 focus:bg-secondary-700 active:bg-secondary-800 focus:shadow-outline-secondary"
    end
  end

  defp get_color_classes(%{color: "white", variant: variant}) do
    case variant do
      "outline" ->
        "border-gray-400 dark:border-gray-300 dark:hover:border-gray-200 dark:hover:text-gray-200 dark:hover:bg-transparent dark:text-gray-300 hover:border-gray-600 text-gray-600 hover:text-gray-700 active:bg-gray-100 hover:bg-gray-50 focus:bg-gray-50 focus:border-gray-500 active:border-gray-600"

      _ ->
        "text-gray-700 bg-white border-gray-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 focus:border-gray-400 focus:bg-gray-100 active:border-gray-400 active:bg-gray-200 active:text-black dark:bg-white dark:hover:bg-gray-200 dark:hover:border-transparent dark:border-transparent"
    end
  end

  defp get_color_classes(%{color: "pure_white", variant: variant}) do
    case variant do
      _ ->
        "text-gray-700 bg-white border-transparent border-white hover:text-gray-900 hover:text-gray-900 hover:border-transparent hover:bg-gray-50 focus:outline-none focus:border-transparent focus:bg-gray-100 focus:text-gray-900 active:border-transparent active:bg-gray-200 active:text-black dark:bg-white dark:hover:bg-gray-200 dark:hover:border-transparent dark:border-transparent"
    end
  end

  defp get_color_classes(%{color: "success", variant: variant}) do
    case variant do
      "outline" ->
        "border-green-400 dark:border-green-400 dark:hover:border-green-300 dark:hover:text-green-300 dark:hover:bg-transparent dark:text-green-400 hover:border-green-600 text-green-600 hover:text-green-700 active:border-green-600 focus:text-green-600 active:text-green-700 active:bg-green-100 hover:bg-green-50 focus:border-green-700"

      _ ->
        "border-transparent text-white bg-green-600 active:bg-green-700 hover:bg-green-700 active:bg-green-700 focus:bg-green-700"
    end
  end

  defp get_color_classes(%{color: "danger", variant: variant}) do
    case variant do
      "outline" ->
        "border-red-400 dark:border-red-400 dark:hover:border-red-300 dark:hover:text-red-300 dark:hover:bg-transparent focus:ring-2 focus:ring-offset-2 focus:ring-red-500 dark:text-red-400 hover:border-red-600 text-red-600 hover:text-red-700 active:bg-red-200 active:border-red-700 hover:bg-red-50 focus:border-red-700"

      _ ->
        "border-transparent text-white bg-red-600 active:bg-red-700 hover:bg-red-700 active:bg-green-700 focus:ring-2 focus:ring-offset-2 focus:ring-red-500 focus:bg-red-700"
    end
  end

  defp get_color_classes(%{color: "warning", variant: variant}) do
    case variant do
      "outline" ->
        "border-yellow-400 dark:border-yellow-400 dark:hover:border-yellow-300 dark:hover:text-yellow-300 dark:hover:bg-transparent dark:text-yellow-400 hover:border-yellow-600 text-yellow-600 hover:text-yellow-700 active:border-yellow-600 focus:text-yellow-600 active:text-yellow-700 active:bg-yellow-100 hover:bg-yellow-50 focus:border-yellow-700"

      _ ->
        "border-transparent text-white bg-yellow-600 active:bg-yellow-700 hover:bg-yellow-700 active:bg-yellow-700 focus:bg-yellow-700"
    end
  end

  defp get_color_classes(%{color: "gray", variant: variant}) do
    case variant do
      "outline" ->
        "border-gray-400 dark:border-gray-400 dark:hover:border-gray-300 dark:hover:text-gray-300 dark:hover:bg-transparent dark:text-gray-400 hover:border-gray-600 text-gray-600 hover:text-gray-700 active:bg-gray-200 active:border-gray-700 hover:bg-gray-50 focus:border-gray-700 focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"

      _ ->
        "border-transparent text-white bg-gray-600 active:bg-gray-700 hover:bg-gray-700 active:bg-green-700 focus:bg-gray-700 focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
    end
  end

  defp get_disabled_classes(true), do: "disabled cursor-not-allowed opacity-50"
  defp get_disabled_classes(false), do: ""

  defp render_icon(nil, _classes), do: nil

  defp render_icon(icon, classes) do
    GuildaWeb.ViewHelpers.svg_icon(icon, class: classes)
  end
end
