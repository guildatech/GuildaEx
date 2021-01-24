defmodule SizeableTest do
  use ExUnit.Case, async: true
  require Sizeable

  doctest Sizeable

  @kilobit 500
  @kilobit_float 500.0
  @kilobit_string "500.0"
  @kilobyte 1024
  @neg -1024
  @zero 0
  @byte 1
  @edgecase 1023

  @fail_value_string "abc"
  @fail_value_atom :abc
  @fail_options {:bits, true}

  # Test for erroneous values
  test "fail" do
    assert_raise RuntimeError, "Value is not a number", fn ->
      Sizeable.filesize(@fail_value_string)
    end
  end

  test "fail atom" do
    assert_raise RuntimeError, "Invalid value", fn ->
      Sizeable.filesize(@fail_value_atom)
    end
  end

  test "fail options" do
    assert_raise RuntimeError, "Invalid options argument", fn ->
      Sizeable.filesize(@kilobyte, @fail_options)
    end
  end

  # Tests for kilobit values
  test "500 B" do
    assert Sizeable.filesize(@kilobit) == "500 B"
  end

  test "500 B float" do
    assert Sizeable.filesize(@kilobit_float) == "500 B"
  end

  test "500 B string" do
    assert Sizeable.filesize(@kilobit_string) == "500 B"
  end

  # Tests for Kilobyte values
  test "1 KB" do
    assert Sizeable.filesize(@kilobyte) == "1 KB"
  end

  test "1 KB round" do
    assert Sizeable.filesize(@kilobyte, round: 1) == "1 KB"
  end

  # Tests for negative values
  test "neg" do
    assert Sizeable.filesize(@neg) == "-1 KB"
  end

  test "neg round" do
    assert Sizeable.filesize(@neg, round: 1) == "-1 KB"
  end

  # Tests for 0
  test "zero round" do
    assert Sizeable.filesize(@zero, round: 1) == "0 B"
  end

  # Tests for the 1023 edge case
  test "edgecase" do
    assert Sizeable.filesize(@edgecase) == "1023 B"
  end

  test "edgecase round" do
    assert Sizeable.filesize(@edgecase, round: 1) == "1023 B"
  end

  # Tests for byte values
  test "byte" do
    assert Sizeable.filesize(@byte) == "1 B"
  end

  test "byte round" do
    assert Sizeable.filesize(@byte, round: 1) == "1 B"
  end
end
