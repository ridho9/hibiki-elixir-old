defmodule Hibiki.Context do
  defstruct client: nil,
            messages: [],
            event: nil,
            replied: false,
            command: nil,
            args: %{}

  @type t :: %__MODULE__{
          client: LineSDK.Client.t(),
          messages: [any],
          event: any,
          replied: bool,
          command: module,
          args: map
        }

  alias Hibiki.Context

  def set_event(ctx, event), do: %{ctx | event: event}

  def set_client(ctx, client), do: %{ctx | client: client}

  def set_command(ctx, cmd), do: %{ctx | command: cmd}

  def add_text_message(%Context{messages: messages} = ctx, text) do
    messages = messages ++ [%{"type" => "text", "text" => text}]
    %{ctx | messages: messages}
  end

  def add_image_message(ctx, original_url) do
    add_image_message(ctx, original_url, original_url)
  end

  def add_image_message(%Context{messages: messages} = ctx, original_url, preview_url) do
    image_message = %{
      "type" => "image",
      "original_content_url" => original_url,
      "preview_image_url" => preview_url
    }

    messages = messages ++ [image_message]
    %{ctx | messages: messages}
  end

  def send_reply(
        %Context{client: client, messages: messages, event: %{"reply_token" => reply_token}} = ctx
      ) do
    LineSDK.Client.send_reply(client, reply_token, messages)
    %{ctx | replied: true}
  end
end
