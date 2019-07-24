defmodule Hibiki.Command.OptionsTest do
  use ExUnit.Case
  alias Hibiki.Command.Options

  test "return empty map for empty string no named" do
    input_options = %Options{}
    input_text = ""
    expected = {:ok, %{}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "return empty map for nil string" do
    input_options = %Options{}
    input_text = nil
    expected = {:ok, %{}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "1 options" do
    input_options = %Options{}
    input_text = "--age 123"
    expected = {:ok, %{"age" => 123}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "1 options rest" do
    input_options = %Options{}
    input_text = "--age 123 rest"
    expected = {:ok, %{"age" => 123, "rest" => "rest"}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "1 options error" do
    input_options = %Options{}
    input_text = "--age"
    expected = {:error, "expected value for option 'age'"}

    assert Options.parse(input_options, input_text) == expected
  end

  test "no named" do
    input_options = %Options{}
    input_text = "rest"
    expected = {:ok, %{"rest" => "rest"}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "flag" do
    input_options = %Options{}
    input_text = "-abc rest"
    expected = {:ok, %{"a" => true, "b" => true, "c" => true, "rest" => "rest"}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "named" do
    input_options = %Options{} |> Options.add_named("name", "")
    input_text = "abc 123"
    expected = {:ok, %{"name" => "abc 123"}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "named with quote" do
    input_options = %Options{} |> Options.add_named("name", "")
    input_text = ~s("qwe asd" 123)
    expected = {:ok, %{"name" => input_text}}

    assert Options.parse(input_options, input_text) == expected
  end

  test "two named" do
    input_options = %Options{} |> Options.add_named("a", "") |> Options.add_named("b", "")
    input_text = ~s(aaa bbb ccc)
    expected = {:ok, %{"a" => "aaa", "b" => "bbb ccc"}}

    assert Options.parse(input_options, input_text) == expected
  end
end
