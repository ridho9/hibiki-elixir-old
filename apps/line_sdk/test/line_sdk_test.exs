defmodule LineSDKTest do
  use ExUnit.Case
  doctest LineSDK

  test "greets the world" do
    assert LineSDK.hello() == :world
  end
end
