defmodule GuildaWeb.MenuLive do
  @moduledoc """
  LiveView to generate the main navigation.
  """
  use GuildaWeb, :live_view

  @impl true
  def mount(_params, %{"menu" => menu, "current_user" => current_user}, socket) do
    {:ok,
     assign(socket,
       menu: menu,
       current_user: current_user,
       entries: menu_entries(socket, menu, current_user)
     ), layout: {GuildaWeb.LayoutView, "navbar.html"}}
  end

  def main_menu_entries(entries) do
    Enum.filter(entries, fn entry -> entry.show && entry.position == :main end)
  end

  def secondary_menu_entries(entries) do
    Enum.filter(entries, fn entry -> entry.show && entry.position == :secondary end)
  end

  def menu_entries(socket, menu, current_user) do
    [
      %{
        menu: menu,
        text: gettext("Podcast"),
        module: GuildaWeb.PodcastEpisodeLive,
        to: Routes.podcast_episode_index_path(socket, :index),
        show: true,
        position: :main
      },
      %{
        menu: menu,
        text: gettext("Members"),
        module: GuildaWeb.MapLive,
        to: Routes.members_path(socket, :show),
        show: true,
        position: :main
      },
      %{
        menu: menu,
        text: gettext("Finances"),
        module: GuildaWeb.FinanceLive,
        to: Routes.finance_index_path(socket, :index),
        show: logged_in?(current_user),
        position: :main
      },
      %{
        menu: menu,
        text: gettext("Settings"),
        module: GuildaWeb.UserSettingLive,
        to: Routes.user_settings_path(socket, :index),
        show: logged_in?(current_user),
        position: :main
      }
    ]
  end

  defp logged_in?(nil), do: false
  defp logged_in?(_user), do: true

  # Template helpers
  def maybe_active_live_redirect(%{menu: menu, text: text, module: module, to: route}, context) do
    classes =
      if to_string(menu.module) =~ to_string(module) do
        active_class(context)
      else
        inactive_class(context)
      end

    live_redirect(text, to: route, class: classes)
  end

  def menu_entry(assigns) do
    %{entry: %{menu: menu, module: module, to: route}, context: context} = assigns

    class =
      if to_string(menu.module) =~ to_string(module) do
        active_class(context)
      else
        inactive_class(context)
      end

    assigns = assign(assigns, :class, class)

    ~H"""
    <.link navigate={@entry.to} class={@class}><%= @entry.text %></.link>
    """
  end

  defp active_class(:main) do
    "inline-flex items-center px-1 pt-1 border-b-2 border-yellow-500 text-sm font-medium leading-5 text-gray-900 focus:outline-none focus:border-yellow-700 transition duration-150 ease-in-out"
  end

  defp active_class(:mobile) do
    "block pl-3 pr-4 py-2 border-l-4 text-base font-medium text-gray-600 bg-yellow-50 border-yellow-300 focus:outline-none focus:text-gray-800 focus:bg-gray-50 focus:border-gray-300 transition duration-150 ease-in-out"
  end

  defp inactive_class(:main) do
    "inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium leading-5 text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out"
  end

  defp inactive_class(:mobile) do
    "block pl-3 pr-4 py-2 border-l-4 border-transparent text-base font-medium text-gray-600 hover:text-gray-800 hover:bg-gray-50 hover:border-gray-300 focus:outline-none focus:text-gray-800 focus:bg-gray-50 focus:border-gray-300 transition duration-150 ease-in-out"
  end
end
