defmodule LineSDK.Parser do
  @moduledoc """
  Parses JSON and arbitary elixir map received from webhook to structs
  """
  alias LineSDK.Models, as: Models

  def parse(%{"type" => "text", "text" => text, "id" => id}) do
    {:ok, %Models.TextMessage{id: id, text: text}}
  end

  def parse(%{"type" => "user", "userId" => user_id}) do
    {:ok, %Models.Source.User{user_id: user_id}}
  end

  def parse(%{"type" => "group", "userId" => user_id, "groupId" => group_id}) do
    {:ok, %Models.Source.Group{user_id: user_id, group_id: group_id}}
  end

  def parse(%{"type" => "room", "userId" => user_id, "roomId" => room_id}) do
    {:ok, %Models.Source.Room{user_id: user_id, room_id: room_id}}
  end

  def parse(%{
        "type" => "message",
        "replyToken" => reply_token,
        "timestamp" => timestamp,
        "source" => source,
        "message" => message
      }) do
    with {:ok, source} <- parse(source),
         {:ok, message} <- parse(message),
         {:ok, timestamp} <- DateTime.from_unix(timestamp, :millisecond) do
      {:ok,
       %Models.MessageEvent{
         reply_token: reply_token,
         source: source,
         message: message,
         timestamp: timestamp
       }}
    end
  end

  def parse(%{"destination" => destination, "events" => events}) do
    events =
      events
      |> Enum.map(&parse/1)
      |> Enum.unzip()

    all_ok =
      events
      |> elem(0)
      |> Enum.any?(fn x -> x == :error end)

    if all_ok do
      {:error, events}
    else
      events = elem(events, 1)

      {:ok,
       %Models.WebhookEvent{
         destination: destination,
         events: events
       }}
    end
  end

  def parse(_), do: {:error, :no_match}
end
