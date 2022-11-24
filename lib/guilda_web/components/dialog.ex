defmodule GuildaWeb.Components.Dialog do
  @moduledoc """
  A modal component.
  """
  use Phoenix.Component
  import GuildaWeb.Components
  import GuildaWeb.Components.Button
  import GuildaWeb.Gettext
  alias GuildaWeb.Icons
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
        <.form let={f} for={@changeset} id="card-form" phx-target={@myself} phx-submit="save">
          ...
        </.form>
        <:cancel><%= gettext("Cancel") %></:cancel>
        <:actions>
          <.button type="submit" form="card-form"><%= gettext("Save") %></.button>
        </:actions>
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

  attr :prevent_click_away, :boolean,
    default: false,
    doc: "set this to prevent closing the modal when clicking outside it"

  slot :title, required: true
  slot :inner_block, required: true
  slot :cancel, required: true
  slot :confirm

  slot :submit do
    attr :id, :string
    attr :form, :string, required: true
    attr :loading_message, :string
  end

  slot :actions

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-hook="RestoreBodyScroll"
      class="relative z-50 hidden"
      data-close={hide_modal(@id)}
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-gray-500 bg-opacity-75" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
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
              phx-click-away={!@prevent_click_away && hide_modal(@on_cancel, @id)}
            >
              <.link :if={@patch} patch={@patch} data-modal-return class="hidden"></.link>
              <.link :if={@navigate} navigate={@navigate} data-modal-return class="hidden"></.link>
              <%= if @type in ~w(confirm delete) do %>
                <div class="w-full pt-4 pl-4 pr-4 text-center sm:text-left">
                  <h3 class="text-lg font-medium leading-6 text-gray-900" id={"#{@id}-title"}>
                    <%= render_slot(@title) %>
                  </h3>
                  <Icons.trash_can :if={@type == "delete"} />
                  <div class="mt-2">
                    <div id={"#{@id}-content"} class="text-base text-gray-500">
                      <%= render_slot(@inner_block) %>
                    </div>
                  </div>
                </div>
                <div class="p-4 sm:flex sm:flex-row-reverse">
                  <button
                    :for={confirm <- @confirm}
                    type="button"
                    id={Map.get(confirm, :id, "#{@id}-confirm")}
                    class={[
                      "inline-flex justify-center w-full px-4 py-2 text-base font-medium text-white border border-transparent rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 sm:ml-3 sm:w-auto sm:text-sm",
                      @type == "delete" && "bg-red-600 hover:bg-red-700 focus:ring-red-500",
                      @type == "confirm" && "bg-primary-600 hover:bg-primary-700 focus:ring-primary-500"
                    ]}
                    phx-click={@on_confirm}
                    {assigns_to_attributes(confirm, [:id])}
                  >
                    <%= render_slot(confirm) %>
                  </button>
                  <.button
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    id={Map.get(cancel, :id, "#{@id}-cancel")}
                    {assigns_to_attributes(cancel, [:id])}
                  >
                    <%= render_slot(cancel) %>
                  </.button>
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
                <div class="px-4 py-3 justify-end bg-white border-t-2 rounded-b-lg sm:px-6 sm:flex sm:space-x-3">
                  <.button
                    :for={cancel <- @cancel}
                    id={Map.get(cancel, :id, "#{@id}-cancel")}
                    phx-click={hide_modal(@on_cancel, @id)}
                    {assigns_to_attributes(cancel, [:id])}
                  >
                    <%= render_slot(cancel) %>
                  </.button>
                  <.button
                    :for={submit <- @submit}
                    type="submit"
                    phx-disable-with={Map.get(submit, :loading_message, gettext("Saving..."))}
                    form={Map.get(submit, :form)}
                    color="primary"
                  >
                    <%= render_slot(submit) %>
                  </.button>
                  <%= if @actions != [], do: render_slot(@actions) %>
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
