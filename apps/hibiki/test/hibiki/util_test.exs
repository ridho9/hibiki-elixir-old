defmodule Hibiki.UtilTest do
  use ExUnit.Case
  alias Hibiki.Util

  test "nil input" do
    input = nil
    expect = {:error, "empty input"}
    assert Util.next_token(input) == expect
  end

  test "empty input" do
    input = ""
    expect = {:error, "empty input"}
    assert Util.next_token(input) == expect
  end

  test "single word" do
    input = "aaa"
    expect = {:ok, "aaa", ""}
    assert Util.next_token(input) == expect
  end

  test "single word 2" do
    input = "aaa bbb"
    expect = {:ok, "aaa", "bbb"}
    assert Util.next_token(input) == expect
  end

  test "single word 3" do
    input = ~s|aaa bbb  |
    expect = {:ok, "aaa", "bbb  "}
    assert Util.next_token(input) == expect
  end

  test "flag" do
    input = ~s[--flag]
    expect = {:ok, "--flag", ""}
    assert Util.next_token(input) == expect
  end

  test "double tick" do
    input = ~s["123 123"  asdf]
    expect = {:ok, "123 123", "asdf"}
    assert Util.next_token(input) == expect
  end

  test "single tick" do
    input = ~s['123 123'  asdf]
    expect = {:ok, "123 123", "asdf"}
    assert Util.next_token(input) == expect
  end

  test "back tick" do
    input = ~s[`123 123`  asdf]
    expect = {:ok, "123 123", "asdf"}
    assert Util.next_token(input) == expect
  end

  test "empty quote" do
    input = ~s[``  asdf]
    expect = {:ok, "", "asdf"}
    assert Util.next_token(input) == expect
  end

  test "tokenize 1" do
    input = ~s[a b c]
    expect = ["a", "b", "c"]
    assert Util.tokenize(input) == expect
  end

  test "tokenize 2" do
    input = ~s[a b c "d e f"]
    expect = ["a", "b", "c", "d e f"]
    assert Util.tokenize(input) == expect
  end

  test "tokenize 3" do
    input = ~s[]
    expect = []
    assert Util.tokenize(input) == expect
  end
end
