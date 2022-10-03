defmodule GuildaWeb.Components.Dialog do
  @moduledoc """
  A modal component.
  """
  use Phoenix.Component
  import GuildaWeb.Components
  import GuildaWeb.Components.Button
  import GuildaWeb.Gettext
  alias Phoenix.LiveView.JS

  @doc """
  This modal is used when you need a delete dialog (by setting type="delete") or as a container
  for other content (usually forms).

  ## Examples
  As a delete modal:

      <Dialog.modal
        type="delete"
        id={"some_id"}
        on_confirm={
          JS.push("delete", value: %{id: some_record_id})
          |> hide_modal("some_id")
          |> hide("#some_record-id")
        }
      >
        <:title><%= gettext("Delete") %></:title>
        <%= gettext("Are you sure you want to remove \"%{name}\"?", name: some_record_name) %>
        <:cancel><%= gettext("Cancel") %></:cancel>
        <:confirm><%= gettext("Delete") %></:confirm>
      </Dialog.modal>


  As a form container:

      <PulseWeb.Components.Dialog.modal id={"form-id-modal"} patch={@return_to} show={true}>
        <:title><%= gettext("Title") %></:title>
        <.form let={f} for={@changeset} id="card-form" phx_target={@myself} phx_submit="save">
          ...
        </.form>
        <:submit form="card-form"><%= gettext("Save") %></:submit>
        <:cancel><%= gettext("Cancel") %></:cancel>
      </PulseWeb.Components.Dialog.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :patch, :string, default: nil
  attr :navigate, :string, default: nil
  attr :max_width, :string, default: "max-w-[720px]"
  attr :type, :string, default: "default", values: ~w(default confirm delete)
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title, required: true
  slot :confirm
  slot :cancel
  slot :extra_footer

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} class="relative z-50 hidden" data-close={hide_modal(@id)}>
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-gray-500 bg-opacity-75" aria-hidden="true" />
      <div class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class={["w-full p-4 sm:p-6 lg:py-8", @max_width]}>
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              class="hidden relative bg-white rounded-lg shadow-xl transition"
              phx-click-away={hide_modal(@on_cancel, @id)}
            >
              <.link :if={@patch} patch={@patch} data-modal-return class="hidden"></.link>
              <.link :if={@navigate} navigate={@navigate} data-modal-return class="hidden"></.link>
              <%= if @type in ~w(confirm delete) do %>
                <div class="w-full pt-4 pl-4 pr-4 text-center sm:text-left">
                  <h3 class="text-lg font-medium leading-6 text-gray-900" id={"#{@id}-title"}>
                    <%= render_slot(@title) %>
                  </h3>
                  <%= if @type == "delete" do %>
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
                  <% end %>
                  <div class="mt-2">
                    <div id={"#{@id}-content"} class={"text-base text-center text-gray-500"}>
                      <%= render_slot(@inner_block) %>
                    </div>
                  </div>
                </div>
                <div class="p-4 sm:flex sm:flex-row-reverse">
                  <button
                    :for={confirm <- @confirm}
                    type="button"
                    id={"#{@id}-confirm"}
                    class={"inline-flex justify-center w-full px-4 py-2 text-base font-medium text-white border border-transparent rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 sm:ml-3 sm:w-auto sm:text-sm #{if @type == "delete", do: "bg-red-600 hover:bg-red-700 focus:ring-red-500", else: "bg-primary-600 hover:bg-primary-700 focus:ring-primary-500"}"}
                    phx-click={@on_confirm}
                    phx-disable-with
                    {assigns_to_attributes(confirm)}
                  >
                    <%= render_slot(confirm) %>
                  </button>
                  <button
                    :for={cancel <- @cancel}
                    type="button"
                    class="inline-flex justify-center w-full px-4 py-2 mt-3 text-base font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:w-auto sm:text-sm"
                    phx-click={hide_modal(@on_cancel, @id)}
                    {assigns_to_attributes(cancel)}
                  >
                    <%= render_slot(cancel) %>
                  </button>
                </div>
              <% else %>
                <div class="flex items-center justify-between px-4 py-3 space-x-2 border-b-2 rounded-t-lg bg-gray-50 sm:px-6 sm:flex">
                  <h2 class="text-lg font-semibold"><%= render_slot(@title) %></h2>
                  <button
                    type="button"
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="absolute flex items-center justify-center w-8 h-8 rounded-full right-4 hover:bg-gray-300 focus:ring-2 focus:ring-primary-500 focus:outline-none"
                    aria-label="close modal"
                  >
                    <Heroicons.x_mark solid class="h-5 w-5 stroke-current" />
                  </button>
                </div>
                <div id={"#{@id}-content"} class="px-4 pt-5 pb-4 overflow-y-auto sm:p-6 sm:pb-4">
                  <%= render_slot(@inner_block) %>
                </div>
                <div class="px-4 py-3 bg-white border-t-2 rounded-b-lg sm:px-6 sm:flex sm:space-x-3 sm:flex-row-reverse">
                  <.button
                    :for={submit <- @submit}
                    type="submit"
                    phx-disable-with={gettext("Saving...")}
                    form={submit[:form]}
                    class="sm:ml-3"
                    color="primary"
                  >
                    <%= render_slot(submit) %>
                  </.button>
                  <%= if @extra_footer != [], do: render_slot(@extra_footer) %>
                  <.button
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    {assigns_to_attributes(cancel)}
                  >
                    <%= render_slot(cancel) %>
                  </.button>
                </div>
              <% end %>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
