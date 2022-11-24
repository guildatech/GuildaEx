defmodule GuildaWeb.Components do
  @moduledoc """
  General components used through the app.
  """
  use Phoenix.Component
  import GuildaWeb.Gettext, warn: false
  alias GuildaWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :rest, :global
  attr :kind, :atom, doc: "one of :info, :error used for styling and flash lookup"
  attr :autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("#flash")}
      role="alert"
      class={[
        "fixed hidden top-2 right-2 w-96 z-50 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 p-3 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
        <Heroicons.information_circle :if={@kind == :info} mini class="h-4 w-4" />
        <Heroicons.exclamation_circle :if={@kind == :error} mini class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-[0.8125rem] leading-5"><%= msg %></p>
      <button :if={@close} type="button" class="group absolute top-2 right-1 p-2" aria-label="Close">
        <Heroicons.x_mark solid class="h-5 w-5 stroke-current opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any
  attr :name, :any
  attr :label, :string, default: nil
  attr :hint, :string, default: nil, doc: "informational text displayed below the input"
  attr :prefix, :string, default: nil, doc: "a prefix to be prepended inside the input field"

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :value, :any
  attr :field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}"
  attr :errors, :list
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :rest, :global, include: ~w(autocomplete disabled form max maxlength min minlength
                                                pattern placeholder readonly required size step)

  attr :hidden_input, :boolean,
    default: true,
    doc: "wether to show or not a hidden input for the unchecked checkbox input"

  slot :inner_block

  slot :entry, doc: "the slot for radio inputs" do
    attr :label, :string
    attr :checked, :boolean
    attr :value, :string, required: true
  end

  def input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn ->
      name = Phoenix.HTML.Form.input_name(f, field)
      if assigns.multiple, do: name <> "[]", else: name
    end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> translate_errors(f.errors || [], field) end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_equals?(assigns.value, "true") end)

    ~H"""
    <label phx-feedback-for={@name} class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
      <input :if={@hidden_input} type="hidden" value="false" />
      <input
        type="checkbox"
        id={@id || @name}
        name={@name}
        value={@value}
        checked={@checked}
        class="rounded border-zinc-300 text-zinc-900 focus:ring-amber-900"
      />
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
    </label>
    """
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label :if={@label} for={@id} aria-hidden="true"><%= @label %></.label>
      <fieldset class={[@label && "mt-1"]}>
        <legend class="sr-only"><%= @label %></legend>
        <div class="space-y-4">
          <div :for={entry <- @entry} class="flex items-center">
            <input
              id={radio_id(@id, entry.value)}
              name={@name}
              type="radio"
              value={entry.value}
              class="h-4 w-4 border-gray-300 text-primary-600 focus:ring-primary-500"
              checked={Map.get_lazy(entry, :checked, fn -> input_equals?(assigns.value, entry.value) end)}
            />
            <label for={radio_id(@id, entry.value)} class="ml-3 block text-sm text-gray-700 cursor-pointer">
              <%= if Map.get(entry, :label) do %>
                <%= entry.label %>
              <% else %>
                <%= render_slot(entry) %>
              <% end %>
            </label>
          </div>
        </div>
      </fieldset>
      <p :if={@hint} class="mt-2 text-sm text-gray-500"><%= @hint %></p>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label :if={@label} for={@id} class="mb-1"><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-amber-500 focus:border-amber-500 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <p :if={@hint} class="mt-2 text-sm text-gray-500"><%= @hint %></p>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label :if={@label} for={@id} class="mb-1"><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          input_border(@errors),
          "mt-2 block min-h-[6rem] w-full rounded-lg border-zinc-300 py-[calc(theme(spacing.2)-1px)] px-[calc(theme(spacing.3)-1px)]",
          "text-zinc-900 focus:border-amber-400 focus:outline-none focus:ring-4 focus:ring-amber-800/5 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-amber-400 phx-no-feedback:focus:ring-amber-800/5"
        ]}
        {@rest}
      ><%= @value %></textarea>
      <p :if={@hint} class="mt-2 text-sm text-gray-500"><%= @hint %></p>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(%{type: "datepicker"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label :if={@label} for={@id} class="mb-1"><%= @label %></.label>
      <div phx-update="ignore" id={"#{@id || @name}-datepicker"} class="mt-1">
        <input
          type="text_input"
          name={@name}
          id={@id || @name}
          value={@value}
          autocomplete="off"
          phx-hook="DatePicker"
          class={[
            input_border(@errors),
            "block w-full rounded-lg border-zinc-300 py-[calc(theme(spacing.2)-1px)] px-[calc(theme(spacing.3)-1px)]",
            "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
            "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-amber-400 phx-no-feedback:focus:ring-zinc-800/5"
          ]}
          {@rest}
        />
      </div>
      <p :if={@hint} class="mt-2 text-sm text-gray-500"><%= @hint %></p>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(%{type: "text", prefix: prefix} = assigns) when not is_nil(prefix) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label :if={@label} for={@id} class="mb-1"><%= @label %></.label>
      <div class="relative mt-1 rounded-md shadow-sm">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <span class="text-gray-500 sm:text-sm"><%= @prefix %></span>
        </div>
        <input
          type="text"
          name={@name}
          id={@id || @name}
          value={@value}
          class={[
            input_border(@errors),
            "block w-full rounded-lg border-zinc-300 py-[calc(theme(spacing.2)-1px)] px-[calc(theme(spacing.3)-1px)]",
            "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
            "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-amber-400 phx-no-feedback:focus:ring-zinc-800/5",
            @prefix && "pl-7"
          ]}
          {@rest}
        />
      </div>
      <p :if={@hint} class="mt-2 text-sm text-gray-500"><%= @hint %></p>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label :if={@label} for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          input_border(@errors),
          "block w-full rounded-lg border-zinc-300 py-[calc(theme(spacing.2)-1px)] px-[calc(theme(spacing.3)-1px)]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-amber-400 phx-no-feedback:focus:ring-zinc-800/5",
          @label && "mt-1"
        ]}
        {@rest}
      />
      <p :if={@hint} class="mt-2 text-sm text-gray-500"><%= @hint %></p>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  defp input_border([] = _errors),
    do: "border-zinc-300 focus:border-amber-400 focus:ring-amber-800/5"

  defp input_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-medium text-gray-700" {@rest}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  attr :message, :string, required: true

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <Heroicons.exclamation_circle mini class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
      <%= @message %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :row_click, JS, default: nil
  attr :row_id, :any, default: nil, doc: "a function used to build each TR element ID"
  attr :rows, :list, required: true

  slot :col, required: true do
    attr :label, :string
    attr :align, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    ~H"""
    <div id={@id} class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
      <table class="min-w-full divide-y divide-gray-300 bg-white">
        <thead class="text-left text-xs uppercase tracking-wide text-zinc-500 bg-gray-50 font-medium">
          <tr>
            <th
              :for={{col, i} <- Enum.with_index(@col)}
              class={["py-3", (i == 0 && "pl-4 pr-3") || "px-3"]}
              align={Map.get(col, :align)}
            >
              <%= col[:label] %>
            </th>
            <th :if={@action != []} class="relative px-3 py-3"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody class="relative divide-y divide-gray-300 text-sm leading-6 text-zinc-700">
          <tr :for={row <- @rows} id={(@row_id && @row_id.(row)) || "#{@id}-#{Phoenix.Param.to_param(row)}"} class="group">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
              align={Map.get(col, :align)}
            >
              <div class={["block py-3", (i == 0 && "pl-4 pr-3") || "px-3"]}>
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-gray-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, row) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative p-0 w-14">
              <div class="relative whitespace-nowrap py-3 px-3 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-gray-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, row) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link navigate={@navigate} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
        <Heroicons.arrow_left solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.dispatch("click", to: "##{id} [data-modal-return]")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(GuildaWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(GuildaWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end

  defp radio_id(id, value) do
    {:safe, value} = Phoenix.HTML.html_escape(value)
    value_id = value |> IO.iodata_to_binary() |> String.replace(~r/\W/u, "_")
    id <> "_" <> value_id
  end

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
          <img
            class="w-auto h-24 mx-auto"
            src={Routes.static_path(GuildaWeb.Endpoint, "/images/guilda-logo.png")}
            alt="GuildaTech logo"
          />
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

  def card(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> nil end)
      |> assign_new(:title, fn -> nil end)
      |> assign_new(:footer, fn -> nil end)
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div id={@id} class={"flex flex-col overflow-hidden bg-white rounded-lg shadow #{@class}"}>
      <%= if @title do %>
        <div class="flex items-center justify-between flex-grow-0 px-4 py-5 text-lg font-bold leading-6 text-gray-900 sm:px-6">
          <%= if is_list(@title), do: render_slot(@title), else: @title %>
        </div>
      <% end %>
      <div class={"flex-grow px-4 pb-5 sm:px-6 #{unless @title, do: "pt-5"}"}>
        <%= render_slot(@inner_block) %>
      </div>
      <%= if @footer do %>
        <div class="px-4 py-3 text-right bg-gray-50 sm:px-6">
          <%= render_slot(@footer) %>
        </div>
      <% end %>
    </div>
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
