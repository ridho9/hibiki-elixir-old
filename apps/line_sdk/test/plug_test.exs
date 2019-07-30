defmodule LineSDK.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts LineSDK.Plug.init(channel_access_token: "cat", channel_secret: "cs")

  test "returns 401 when missing x-line-signature" do
    conn =
      :post
      |> conn("/")
      |> LineSDK.Plug.call(@opts)

    assert conn.status == 401
  end

  test "returns 400 when not json" do
    conn =
      :post
      |> conn("/", "ahehehe")
      |> put_req_header("x-line-signature", "1234")
      |> put_req_header("content-type", "text/plain")
      |> LineSDK.Plug.call(@opts)

    assert conn.status == 400
  end

  test "returns 401 when signature doesn't match" do
    conn =
      :post
      |> conn("/", ~S({"a": 1}))
      |> put_req_header("x-line-signature", "1234")
      |> put_req_header("content-type", "application/json")
      |> LineSDK.Plug.call(@opts)

    assert conn.status == 401
  end

  test "returns 200 when signature match" do
    conn =
      :post
      |> conn("/", ~S({"events": []}))
      |> put_req_header("x-line-signature", "5FjeSIDeeopATDtOCRvTreK7yBLWJLSsEKINECUhVt4=")
      |> put_req_header("content-type", "application/json")
      |> LineSDK.Plug.call(@opts)

    assert conn.status == 200
  end
end
