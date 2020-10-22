defmodule GuildaWeb.ViewHelpers do
  @moduledoc """
  View Helpers used across the app.
  """

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
