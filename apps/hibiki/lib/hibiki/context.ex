defmodule Hibiki.Context do
  defstruct client: nil,
            messages: [],
            event: nil,
            replied: false,
            command: nil,
            args: %{},
            start_time: nil

  @type t :: %__MODULE__{
          client: LineSDK.Client.t(),
          messages: [any],
          event: any,
          replied: bool,
          command: module,
          args: map,
          start_time: DateTime.t()
        }

  alias Hibiki.Context

  def start_now(ctx) do
    %{ctx | start_time: DateTime.utc_now()}
  end

  def set_event(ctx, event), do: %{ctx | event: event}

  def set_client(ctx, client), do: %{ctx | client: client}

  def set_command(ctx, cmd), do: %{ctx | command: cmd}

  def add_text_message(ctx, text) do
    text_messages = %{"type" => "text", "text" => text}
    add_message(ctx, text_messages)
  end

  def add_image_message(ctx, original_url) do
    add_image_message(ctx, original_url, original_url)
  end

  def add_image_message(ctx, original_url, preview_url) do
    image_message = %{
      "type" => "image",
      "original_content_url" => original_url,
      "preview_image_url" => preview_url
    }

    add_message(ctx, image_message)
  end

  def add_message(%Context{messages: messages} = ctx, message) do
    %{ctx | messages: messages ++ [message]}
  end

  def send_reply(
        %Context{client: client, messages: messages, event: %{"reply_token" => reply_token}} = ctx
      ) do
    LineSDK.Client.send_reply(client, reply_token, messages)

    %{ctx | replied: true}
  end
end
