defmodule Hibiki.Context do
  defstruct client: nil, messages: [], event: nil, replied: false

  alias Hibiki.Context

  def set_event(ctx, event) do
    %{ctx | event: event}
  end

  def set_client(ctx, client) do
    %{ctx | client: client}
  end

  def add_text_message(%Context{messages: messages} = ctx, text) do
    messages = messages ++ [%{"type" => "text", "text" => text}]
    %{ctx | messages: messages}
  end

  def send_reply(
        %Context{client: client, messages: messages, event: %{"reply_token" => reply_token}} = ctx
      ) do
    LineSDK.Client.send_reply(client, reply_token, messages)
    %{ctx | replied: true}
  end
end
