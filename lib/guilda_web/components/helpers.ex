defmodule GuildaWeb.Components.Helpers do
  @doc """
  Remove newlines and extra spaces from a string
  """
  def convert_string_to_one_line(string) when is_binary(string) do
    string
    |> String.replace("\r", " ")
    |> String.replace("\n", " ")
    |> String.split()
    |> Enum.join(" ")
  end
end
