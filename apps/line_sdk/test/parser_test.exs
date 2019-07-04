defmodule LineSDK.ParserTest do
  use ExUnit.Case
  doctest LineSDK
  alias LineSDK.Models, as: Models
  alias LineSDK.Parser, as: Parser

  test "parse text event message" do
    input = %{"type" => "text", "id" => "123", "text" => "test"}
    expect = %Models.TextMessage{id: "123", text: "test"}
    assert Parser.parse(input) == {:ok, expect}
  end

  test "parse source user" do
    input = %{"type" => "user", "userId" => "uid"}
    expect = %Models.Source.User{user_id: "uid"}
    assert Parser.parse(input) == {:ok, expect}
  end

  test "parse source group" do
    input = %{"type" => "group", "userId" => "uid", "groupId" => "gid"}
    expect = %Models.Source.Group{user_id: "uid", group_id: "gid"}
    assert Parser.parse(input) == {:ok, expect}
  end

  test "parse source room" do
    input = %{"type" => "room", "userId" => "uid", "roomId" => "gid"}
    expect = %Models.Source.Room{user_id: "uid", room_id: "gid"}
    assert Parser.parse(input) == {:ok, expect}
  end

  test "parse message event" do
    input = %{
      "replyToken" => "rt",
      "timestamp" => 1234,
      "type" => "message",
      "source" => %{
        "type" => "user",
        "userId" => "uid"
      },
      "message" => %{
        "id" => "1234",
        "type" => "text",
        "text" => "hello"
      }
    }

    expect = %Models.MessageEvent{
      reply_token: "rt",
      timestamp: DateTime.from_unix!(1234, :millisecond),
      source: %Models.Source.User{user_id: "uid"},
      message: %Models.TextMessage{id: "1234", text: "hello"}
    }

    assert Parser.parse(input) == {:ok, expect}
  end

  test "parse webhook event success" do
    input = %{
      "replyToken" => "rt",
      "timestamp" => 1234,
      "type" => "message",
      "source" => %{
        "type" => "user",
        "userId" => "uid"
      },
      "message" => %{
        "id" => "1234",
        "type" => "text",
        "text" => "hello"
      }
    }

    input = %{
      "destination" => "dest",
      "events" => [input]
    }

    expect = %Models.MessageEvent{
      reply_token: "rt",
      timestamp: DateTime.from_unix!(1234, :millisecond),
      source: %Models.Source.User{user_id: "uid"},
      message: %Models.TextMessage{id: "1234", text: "hello"}
    }

    expect = %Models.WebhookEvent{
      destination: "dest",
      events: [expect]
    }

    assert Parser.parse(input) == {:ok, expect}
  end

  test "parse webhook event fail" do
    input = %{
      "type" => "message",
      "source" => %{
        "type" => "user"
      },
      "message" => %{}
    }

    input = %{
      "destination" => "dest",
      "events" => [input]
    }

    {code, _} = Parser.parse(input)
    assert code == :error
  end
end
