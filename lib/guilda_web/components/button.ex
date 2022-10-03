# credo:disable-for-this-file Credo.Check.Readability.MaxLineLength
defmodule GuildaWeb.Components.Button do
  use Phoenix.Component

  @doc """
  Renders a button or a link styled as a button.
  """
  attr(:type, :string, default: "button")
  attr(:patch, :string, default: nil)
  attr(:navigate, :string, default: nil)
  attr(:href, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:override_class, :boolean, default: false)
  attr(:rounded, :boolean, default: false)

  attr(:variant, :string, default: "default", values: ~w(default outline))

  attr(:color, :string,
    default: "white",
    values: ~w(primary secondary white success danger)
  )

  attr(:loading, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(xs sm md lg xl))
  attr(:label, :string, default: nil)
  attr(:rest, :global, doc: "the arbitrary HTML attributes to apply to the button tag")

  slot(:inner_block)

  def button(%{navigate: navigate, patch: patch, href: href} = assigns)
      when is_binary(navigate) or is_binary(patch) or is_binary(href) do
    ~H"""
    <.link patch={@patch} navigate={@navigate} href={@href} class={button_classes(assigns)} {@rest}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
    </.link>
    """
  end

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={button_classes(assigns)}
      {@rest}
    >
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
    </button>
    """
  end

  @doc false
  def button_classes(opts) do
    if opts.override_class do
      opts.class
    else
      [
        get_color_classes(opts),
        size_css(opts.size),
        rounded_classes(opts),
        "disabled:opacity-50 disabled:cursor-not-allowed",
        "font-medium",
        "border",
        "inline-flex items-center justify-center",
        "transition duration-150 ease-in-out",
        "focus:outline-none",
        opts.class
      ]
    end
  end

  defp rounded_classes(opts) do
    if opts.rounded do
      "rounded-full"
    else
      "rounded-md"
    end
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

  defp get_color_classes(%{color: "primary", variant: variant}) do
    case variant do
      "outline" ->
        "border-primary-400 dark:border-primary-400 dark:hover:border-primary-300 dark:hover:text-primary-300 dark:hover:bg-transparent dark:text-primary-400 hover:border-primary-600 text-primary-600 hover:text-primary-700 active:bg-primary-200 hover:bg-primary-50 focus:border-primary-700 focus:shadow-outline-primary"

      "default" ->
        "border-transparent text-white bg-primary-600 active:bg-primary-700 hover:bg-primary-700 focus:bg-primary-700 active:bg-primary-800 focus:shadow-outline-primary"
    end
  end

  defp get_color_classes(%{color: "secondary", variant: variant}) do
    case variant do
      "outline" ->
        "border-secondary-400 dark:border-secondary-400 dark:hover:border-secondary-300 dark:hover:text-secondary-300 dark:hover:bg-transparent dark:text-secondary-400 hover:border-secondary-600 text-secondary-600 hover:text-secondary-700 active:bg-secondary-200 hover:bg-secondary-50 focus:border-secondary-700 focus:shadow-outline-secondary"

      "default" ->
        "border-transparent text-white bg-secondary-600 active:bg-secondary-700 hover:bg-secondary-700 focus:bg-secondary-700 active:bg-secondary-800 focus:shadow-outline-secondary"
    end
  end

  defp get_color_classes(%{color: "white", variant: variant}) do
    case variant do
      "outline" ->
        "border-gray-400 dark:border-gray-300 dark:hover:border-gray-200 dark:hover:text-gray-200 dark:hover:bg-transparent dark:text-gray-300 hover:border-gray-600 text-gray-600 hover:text-gray-700 active:bg-gray-100 hover:bg-gray-50 focus:bg-gray-50 focus:border-gray-500 active:border-gray-600"

      "default" ->
        "text-gray-700 bg-white border-gray-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 focus:border-gray-400 focus:bg-gray-100 active:border-gray-400 active:bg-gray-200 active:text-black dark:bg-white dark:hover:bg-gray-200 dark:hover:border-transparent dark:border-transparent"
    end
  end

  defp get_color_classes(%{color: "success", variant: variant}) do
    case variant do
      "outline" ->
        "border-green-400 dark:border-green-400 dark:hover:border-green-300 dark:hover:text-green-300 dark:hover:bg-transparent dark:text-green-400 hover:border-green-600 text-green-600 hover:text-green-700 active:border-green-600 focus:text-green-600 active:text-green-700 active:bg-green-100 hover:bg-green-50 focus:border-green-700"

      "default" ->
        "border-transparent text-white bg-green-600 active:bg-green-700 hover:bg-green-700 active:bg-green-700 focus:bg-green-700"
    end
  end

  defp get_color_classes(%{color: "danger", variant: variant}) do
    case variant do
      "outline" ->
        "border-red-400 dark:border-red-400 dark:hover:border-red-300 dark:hover:text-red-300 dark:hover:bg-transparent focus:ring-2 focus:ring-offset-2 focus:ring-red-500 dark:text-red-400 hover:border-red-600 text-red-600 hover:text-red-700 active:bg-red-200 active:border-red-700 hover:bg-red-50 focus:border-red-700"

      "default" ->
        "border-transparent text-white bg-red-600 active:bg-red-700 hover:bg-red-700 active:bg-green-700 focus:ring-2 focus:ring-offset-2 focus:ring-red-500 focus:bg-red-700"
    end
  end
end
