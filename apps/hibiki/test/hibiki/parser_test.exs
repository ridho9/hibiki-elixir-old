defmodule Hibiki.ParserTest do
  use ExUnit.Case
  alias Hibiki.Parser

  test "nil input" do
    input = nil
    expect = {:error, "empty input"}
    assert Parser.next_token(input) == expect
  end

  test "empty input" do
    input = ""
    expect = {:error, "empty input"}
    assert Parser.next_token(input) == expect
  end

  test "single word" do
    input = "aaa"
    expect = {:ok, "aaa", ""}
    assert Parser.next_token(input) == expect
  end

  test "single word 2" do
    input = "aaa bbb"
    expect = {:ok, "aaa", "bbb"}
    assert Parser.next_token(input) == expect
  end

  test "single word 3" do
    input = ~s|aaa bbb  |
    expect = {:ok, "aaa", "bbb  "}
    assert Parser.next_token(input) == expect
  end

  test "flag" do
    input = ~s[--flag]
    expect = {:ok, "--flag", ""}
    assert Parser.next_token(input) == expect
  end

  test "double tick" do
    input = ~s["123 123"  asdf]
    expect = {:ok, "123 123", "asdf"}
    assert Parser.next_token(input) == expect
  end

  test "single tick" do
    input = ~s['123 123'  asdf]
    expect = {:ok, "123 123", "asdf"}
    assert Parser.next_token(input) == expect
  end

  test "back tick" do
    input = ~s[`123 123`  asdf]
    expect = {:ok, "123 123", "asdf"}
    assert Parser.next_token(input) == expect
  end

  test "empty quote" do
    input = ~s[``  asdf]
    expect = {:ok, "", "asdf"}
    assert Parser.next_token(input) == expect
  end

  test "tokenize 1" do
    input = ~s[a b c]
    expect = ["a", "b", "c"]
    assert Parser.tokenize(input) == expect
  end

  test "tokenize 2" do
    input = ~s[a b c "d e f"]
    expect = ["a", "b", "c", "d e f"]
    assert Parser.tokenize(input) == expect
  end

  test "tokenize 3" do
    input = ~s[]
    expect = []
    assert Parser.tokenize(input) == expect
  end
end
