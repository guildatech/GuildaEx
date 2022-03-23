defmodule GuildaWeb.Components.Dialog do
  use Phoenix.Component
  import GuildaWeb.Components
  import GuildaWeb.Components.Link
  alias Phoenix.LiveView.JS

  def delete_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:show, fn -> false end)
      |> assign_new(:patch, fn -> nil end)
      |> assign_new(:navigate, fn -> nil end)
      |> assign_new(:on_cancel, fn -> %JS{} end)
      |> assign_new(:on_confirm, fn -> %JS{} end)
      # slots
      |> assign_new(:title, fn -> [] end)
      |> assign_new(:confirm, fn -> [] end)
      |> assign_new(:cancel, fn -> [] end)
      |> assign_rest(~w(id show patch navigate on_cancel on_confirm title confirm cancel)a)

    ~H"""
    <div id={@id} class={"fixed z-50 inset-0 overflow-y-auto #{if @show, do: "fade-in", else: "hidden"}"} {@rest}>
      <.focus_wrap id={"#{@id}-focus-wrap"} content={"##{@id}-container"}>
        <div class="flex items-end justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0" aria-labelledby={"#{@id}-title"} aria-describedby={"#{@id}-description"} role="dialog" aria-modal="true" tabindex="0">
          <div class="fixed inset-0 transition-opacity bg-gray-500 bg-opacity-75" aria-hidden="true"></div>
          <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
          <div
            id={"#{@id}-container"}
            class={"#{if @show, do: "fade-in-scale", else: "hidden"} sticky inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform sm:my-8 sm:align-middle sm:max-w-xl sm:w-full sm:p-6"}
            phx-window-keydown={hide_modal(@on_cancel, @id)} phx-key="escape"
            phx-click-away={hide_modal(@on_cancel, @id)}
          >
            <%= if @patch do %>
              <.link link_type="live_patch" to={@patch} data-modal-return class="hidden"></.link>
            <% end %>
            <%= if @navigate do %>
              <.link link_type="live_redirect" to={@navigate} data-modal-return class="hidden"></.link>
            <% end %>
            <div class="sm:flex sm:items-start">
              <div class="w-full mt-3 mr-12 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 class="text-lg font-medium leading-6 text-gray-900" id={"#{@id}-title"}>
                  <%= render_slot(@title) %>
                </h3>
                <svg class="mx-auto" width="123" height="119" viewBox="0 0 123 119" xmlns="http://www.w3.org/2000/svg">
                  <g fill="none" fill-rule="evenodd">
                    <path d="M7.733 99.747L106.73 55.83a9.261 9.261 0 0112.21 4.688 9.211 9.211 0 01-4.651 12.168l-.023.01-98.998 43.917a9.261 9.261 0 01-12.21-4.688A9.211 9.211 0 017.71 99.757l.023-.01z" stroke="#cd000a" stroke-width="3" fill="#ffeded" fill-rule="nonzero" />
                    <path stroke="#cd000a" stroke-width="3" fill="#fff" fill-rule="nonzero" d="M23.407 16.5h76v62.425L26.245 110.5z" />
                    <g transform="translate(23.407 16.5)">
                      <path stroke="#cd000a" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" d="M25.5 28v21.266" />
                      <path fill="#ffeded" fill-rule="nonzero" d="M62 0h14v63.076L62 70z" />
                      <path stroke="#cd000a" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" d="M38.5 21v35M50.5 28v21.266" />
                      <path stroke="#cd000a" stroke-width="3" d="M0 0h76v62.425L2.838 94z" />
                    </g>
                    <path d="M91.407 7.5h9.5a4.5 4.5 0 010 9h-9.5v-9z" fill="#ffeded" fill-rule="nonzero" />
                    <rect stroke="#cd000a" stroke-width="3" fill="#fff" fill-rule="nonzero" x="15.407" y="7.5" width="90" height="9" rx="4.5" />
                    <rect stroke="#cd000a" stroke-width="3" x="15.407" y="7.5" width="90" height="9" rx="4.5" />
                    <rect stroke="#cd000a" stroke-width="3" fill="#ffeded" fill-rule="nonzero" x="48.407" y="1.5" width="26" height="6" rx="3" />
                  </g>
                </svg>
                <div class="mt-2">
                  <p id={"#{@id}-content"} class={"text-base text-center text-gray-500"}>
                    <%= render_slot(@inner_block) %>
                  </p>
                </div>
              </div>
            </div>
            <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
              <%= for confirm <- @confirm do %>
                <button
                  id={"#{@id}-confirm"}
                  class="inline-flex justify-center w-full px-4 py-2 text-base font-medium text-white bg-red-600 border border-transparent rounded-md shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm"
                  phx-click={@on_confirm}
                  phx-disable-with
                  {assigns_to_attributes(confirm)}
                >
                  <%= render_slot(confirm) %>
                </button>
              <% end %>
              <%= for cancel <- @cancel do %>
                <button
                  class="inline-flex justify-center w-full px-4 py-2 mt-3 text-base font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:w-auto sm:text-sm"
                  phx-click={hide_modal(@on_cancel, @id)}
                  {assigns_to_attributes(cancel)}
                >
                  <%= render_slot(cancel) %>
                </button>
              <% end %>
            </div>
          </div>
        </div>
      </.focus_wrap>
    </div>
    """
  end
end
