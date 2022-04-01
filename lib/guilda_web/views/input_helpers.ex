defmodule GuildaWeb.InputHelpers do
  @moduledoc false

  use Phoenix.HTML

  alias GuildaWeb.ErrorHelpers
  alias Phoenix.HTML.Form

  def input(form, field, nil, opts), do: input(form, field, input_opts: opts)

  def input(form, field, opts \\ [])
  def input(form, field, label) when not is_list(label), do: input(form, field, label: label)

  def input(form, field, opts) do
    input_opts =
      Keyword.merge(
        [class: form_input_classes(form, field), phx_feedback_for: input_id(form, field)],
        Keyword.get(opts, :input_opts, [])
      )

    type = Keyword.get(opts, :type) || Form.input_type(form, field)
    input = [apply(Form, type, [form, field, input_opts])]

    content_tag :div, class: "form-control space-y-1" do
      [
        build_label(form, field, opts),
        content_tag :div, class: "form-control__wrapper" do
          [input, ErrorHelpers.error_icon(form, field)]
        end,
        build_hint(opts[:hint]),
        ErrorHelpers.error_tag(form, field)
      ]
    end
  end

  # sobelow_skip ["XSS.Raw"]
  def select_input(form, field, opts) do
    input_opts =
      Keyword.merge(
        [class: form_input_classes(form, field) <> " form-select"],
        Keyword.get(opts, :input_opts, [])
      )

    input = [Form.select(form, field, Keyword.fetch!(opts, :entries), input_opts)]

    content_tag :div, class: "form-control space-y-1" do
      [
        build_label(form, field, opts),
        input,
        ErrorHelpers.error_tag(form, field)
      ]
    end
  end

  @doc """
  Generates the inline error class for form inputs.
  """
  def form_input_classes(form, field) do
    if form.errors[field] do
      "form-control__input form-control__input--with-errors"
    else
      "form-control__input"
    end
  end

  defp build_label(form, field, opts) do
    label_text = Keyword.get(opts, :label)
    label_opts = Keyword.merge([class: "form-control__label"], Keyword.get(opts, :label_opts, []))

    if label_text do
      label(form, field, label_text, label_opts)
    else
      label(form, field, label_opts)
    end
  end

  defp build_hint(nil), do: []

  defp build_hint(text) do
    content_tag(:p, text, class: "mt-2 text-sm text-gray-500")
  end
end
