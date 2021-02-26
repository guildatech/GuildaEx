defmodule GuildaWeb.ViewHelpers do
  @moduledoc """
  View Helpers used across the app.
  """

  @spec format_date(Timex.Types.valid_datetime()) :: String.t() | no_return()
  def format_date(date) do
    Timex.format!(date, "{0D}/{0M}/{YYYY}")
  end

  @doc """
  Format the given number of seconds in hh:mm:ss.
  """
  def format_seconds(seconds) do
    seconds |> Timex.Duration.from_seconds() |> Timex.Duration.to_time!()
  end

  def svg_icon(match, opts \\ [])

  for file <- Guilda.svg_icons() do
    match = Path.basename(file, ".svg")
    atom = String.to_atom(match)
    Module.register_attribute(__MODULE__, atom, persist: true)
    Module.put_attribute(__MODULE__, atom, File.read!(file))

    def svg_icon(unquote(match), []), do: hd(__MODULE__.__info__(:attributes)[unquote(atom)])

    # sobelow_skip ["XSS"]
    def svg_icon(unquote(match), opts) do
      opts
      |> Enum.reduce(Floki.parse_fragment!(svg_icon(unquote(match), [])), fn {k, v}, svg ->
        Floki.attr(svg, "svg", "#{k}", fn _ -> "#{v}" end)
      end)
      |> Floki.raw_html()
      |> Phoenix.HTML.raw()
    end
  end
end
