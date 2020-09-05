defmodule Guilda do
  @moduledoc """
  Guilda keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @icon_path Path.relative_to_cwd(Path.join("assets", "icons"))
  @spec svg_icons() :: [binary()]
  def svg_icons(), do: recursive(@icon_path)

  defp recursive(path) do
    Enum.reduce(File.ls!(path), [], fn file, acc ->
      path = Path.join(path, file)
      if File.dir?(path), do: recursive(path) ++ acc, else: [path | acc]
    end)
  end
end
