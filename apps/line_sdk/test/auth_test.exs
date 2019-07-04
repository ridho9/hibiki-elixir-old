defmodule LineSDK.AuthTest do
  use ExUnit.Case

  test "calculate correct signature" do
    secret = "secret"
    message = "message"
    expected = "i19IcCmVwVmMVz2x4hhmqbgl1KeU0WnXBgoDYFeWNgs="

    assert LineSDK.Auth.calculate_signature(message, secret) == expected
  end

  test "calculate correct signature non-ascii" do
    secret = "secret"
    message = "漢字"
    expected = "ak0/upRMxeYmfNCEQm7CrLN6zKTADbf8Un8L0xhlOYk="

    assert LineSDK.Auth.calculate_signature(message, secret) == expected
  end
end
