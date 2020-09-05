defmodule GuildaWeb.InputHelpers do
  @moduledoc false

  use Phoenix.HTML

  alias GuildaWeb.ErrorHelpers
  alias Phoenix.HTML.Form

  def input(form, field, opts) when is_list(opts), do: input(form, field, nil, opts)

  def input(form, field, label_text \\ nil, input_opts \\ []) do
    label_opts = [class: "form-control__label"]

    label =
      if label_text do
        label(form, field, label_text, label_opts)
      else
        label(form, field, label_opts)
      end

    type = Form.input_type(form, field)
    input_opts = Keyword.merge([class: form_input_classes(form, field)], input_opts)
    input = [apply(Form, type, [form, field, input_opts])]

    error = ErrorHelpers.error_tag(form, field)
    error_icon = ErrorHelpers.error_icon(form, field)

    content_tag :div, class: "form-control" do
      [
        label,
        content_tag :div, class: "form-control__wrapper" do
          [input, error_icon]
        end,
        error
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
end
