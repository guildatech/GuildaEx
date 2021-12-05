defmodule GuildaWeb.Helpers do
  @moduledoc """
  General helpers used through the app.
  """
  use Phoenix.Component

  import GuildaWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Wraps the given content in a modal dialog.
  When closed, the modal redirects to the given `:return_to` URL.
  ## Example
      <.live_modal return_to={...}>
        <.live_component module={MyComponent}  />
      </.live_modal>
  """
  def modal(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div class="fixed z-[10000] inset-0 fade-in" phx-remove={JS.transition("fade-out")}>
      <!-- Modal container -->
      <div class="flex items-center justify-center h-screen p-4">
        <!-- Overlay -->
        <div class="absolute inset-0 z-0 bg-gray-500 opacity-75" aria-hidden="true"></div>
        <!-- Modal box -->
        <div class={"relative flex flex-col max-h-full bg-white rounded-lg shadow-xl #{@class}"}
          role="dialog"
          aria-modal="true"
          tabindex="0"
          autofocus
          phx-keydown={click_modal_close()}
          phx-key="escape">
          <!-- Modal header -->
            <div class="flex items-center justify-between px-4 py-4 space-x-2 border-b-2 rounded-t-lg bg-gray-50 sm:px-6 sm:flex">
              <h2><%= @title %></h2>
              <%= live_patch to: @return_to,
                    class: "flex space-x-1 items-center text-gray-500",
                    aria_label: "close modal",
                    id: "close-modal-button" do %>
                <.remix_icon icon="close-line" class="text-2xl" />
              <% end %>
            </div>
          <!-- Modal body -->
          <div class="px-4 pt-5 pb-4 overflow-y-auto sm:p-6 sm:pb-4">
            <%= render_slot(@inner_block) %>
          </div>
          <!-- Modal footer -->
          <div class="px-4 py-3 space-x-2 rounded-b-lg bg-gray-50 sm:px-6 sm:flex">
            <button type="button" class="Button Button--secondary sm:ml-auto" phx-click={click_modal_close()}><%= gettext("Cancelar") %></button>
            <%= render_slot(@footer) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp click_modal_close(js \\ %JS{}) do
    JS.dispatch(js, "click", to: "#close-modal-button")
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
