defmodule GuildaWeb.MenuLive do
  use GuildaWeb, :live_view

  @impl true
  def mount(_params, %{"menu" => menu, "current_user" => current_user}, socket) do
    {:ok, assign(socket, menu: menu, current_user: current_user)}
  end

  # Template helpers
  def maybe_active_live_redirect(menu, text, context, module, route) do
    if menu.module == module do
      content_tag(:div, text, class: active_class(context))
    else
      live_redirect(text,
        to: route,
        class: inactive_class(context)
      )
    end
  end

  defp active_class(:main) do
    "inline-flex items-center px-1 pt-1 border-b-2 border-yellow-500 text-sm font-medium leading-5 text-gray-900 focus:outline-none focus:border-yellow-700 transition duration-150 ease-in-out"
  end

  defp active_class(:mobile) do
    "block pl-3 pr-4 py-2 border-l-4 border-yellow-500 text-base font-medium text-yellow-700 bg-yellow-50 focus:outline-none focus:text-yellow-800 focus:bg-yellow-100 focus:border-yellow-700 transition duration-150 ease-in-out"
  end

  defp inactive_class(:main) do
    "inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium leading-5 text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out"
  end

  defp inactive_class(:mobile) do
    "inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium leading-5 text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out"
  end
end
