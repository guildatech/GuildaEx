defmodule GuildaWeb.Mjml do
  @moduledoc """
  This module uses the MJML Rust implementation (mrml) to compile templates to HTML
  """

  require Logger

  @doc """
  Compile a MJML template to HTML, where `email_or_template` can be:

    * `Swoosh.Email`
    * literal MJML template string
    * literal HTML template string

  ## Examples

      iex> compile!("<mj-body>")
      "<!doctype html>..."

      iex> compile!("<html>")
      "<html>..."

      iex> compile!(%Swoosh.Email{html_body: "<mj-body>"})
      %Swoosh.Email{html_body: "<!doctype html>..."}

      iex> compile!(%Swoosh.Email{html_body: "<html>"})
      %Swoosh.Email{html_body: "<html>..."}

  """
  @type compiled_template :: String.t() | Swoosh.Email.t()
  @spec compile!(String.t() | Swoosh.Email.t()) :: compiled_template()
  def compile!(email_or_template)

  def compile!(%Swoosh.Email{html_body: body} = email) do
    Map.put(email, :html_body, compile!(body))
  end

  def compile!(email_or_template) when is_binary(email_or_template) do
    if email_or_template =~ "<mjml>", do: do_compile_mjml!(email_or_template), else: email_or_template
  end

  def compile!(email_or_template) do
    raise ArgumentError,
          "Expected either a %Swoosh.Email{} or valid HTML or MJML template, got: #{inspect(email_or_template)}"
  end

  defp do_compile_mjml!(template) do
    case Mjml.to_html(template) do
      {:ok, html} -> html
      {:error, error} -> raise "Mjml compilation returned #{inspect(error)}, mail has not been compiled."
    end
  end
end
