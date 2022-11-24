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
end
