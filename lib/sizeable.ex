defmodule Sizeable do
  @moduledoc """
  A library to make file sizes human-readable.

  Forked from https://github.com/arvidkahl/sizeable under MIT.
  """

  @bytes ~w(B KB MB GB TB PB EB ZB YB)

  @doc """
  see `filesize(value, options)`
  """
  def filesize(value) do
    filesize(value, [])
  end

  def filesize(value, options) when is_bitstring(value) do
    case Integer.parse(value) do
      {parsed, _rem} -> filesize(parsed, options)
      :error -> raise "Value is not a number"
    end
  end

  def filesize(value, options) when is_integer(value) do
    {parsed, _rem} = value |> Integer.to_string() |> Float.parse()
    filesize(parsed, options)
  end

  def filesize(0.0, _options) do
    {:ok, unit} = Enum.fetch(@bytes, 0)

    filesize_output(0, unit)
  end

  @doc """
  Returns a human-readable string for the given numeric value.

  ## Arguments:
  - `value` (Integer/Float/String) representing the filesize to be converted.
  - `options` (Struct) representing the options to determine base, rounding and units.

  ## Options
  - `round`: the precision that the number should be rounded down to. Defaults to `2`.
  - `base`: the base for exponent calculation. `2` for binary-based numbers, any other Integer can be used. Defaults to `2`.
  """
  def filesize(value, options) when is_float(value) and is_list(options) do
    base = Keyword.get(options, :base, 2)
    round = Keyword.get(options, :round, 2)

    ceil =
      if base > 2 do
        1000
      else
        1024
      end

    neg = value < 0

    value =
      case neg do
        true -> -value
        false -> value
      end

    {exponent, _rem} =
      (:math.log(value) / :math.log(ceil))
      |> Float.floor()
      |> Float.to_string()
      |> Integer.parse()

    result = Float.round(value / :math.pow(ceil, exponent), base)

    result =
      if Float.floor(result) == result do
        round(result)
      else
        Float.round(result, round)
      end

    {:ok, unit} = Enum.fetch(@bytes, exponent)

    result =
      case neg do
        true -> result * -1
        false -> result
      end

    filesize_output(result, unit)
  end

  def filesize(_value, options) when is_list(options) do
    raise "Invalid value"
  end

  def filesize(_value, _options) do
    raise "Invalid options argument"
  end

  def filesize_output(result, unit) do
    Enum.join([result, unit], " ")
  end
end
