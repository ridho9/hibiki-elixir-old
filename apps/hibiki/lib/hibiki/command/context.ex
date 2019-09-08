defmodule Hibiki.Command.Context do
  defstruct client: nil,
            messages: [],
            event: nil,
            replied: false,
            command: nil,
            args: %{},
            start_time: nil

  @type t :: %__MODULE__{
          client: LineSDK.Client.t() | nil,
          messages: [any],
          event: map | nil,
          replied: bool,
          command: module | nil,
          args: map,
          start_time: DateTime.t() | nil
        }

  alias __MODULE__

  def start_now(ctx), do: %{ctx | start_time: DateTime.utc_now()}

  def set_event(ctx, event), do: %{ctx | event: event}

  def set_client(ctx, client), do: %{ctx | client: client}

  def set_command(ctx, cmd), do: %{ctx | command: cmd}

  def add_text_message(ctx, text) do
    text_messages = %{"type" => "text", "text" => text}
    add_message(ctx, text_messages)
  end

  def add_error(ctx, err) do
    add_text_message(ctx, "Ugh... #{err}")
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

defmodule Hibiki.Command.Context.Source do
  alias Hibiki.Command.Context

  @spec user_id(Context.t()) :: String.t()
  def user_id(%Context{event: %{"source" => %{"user_id" => user_id}}}), do: user_id

  @spec scope_type(Context.t()) :: String.t()
  def scope_type(%Context{event: %{"source" => %{"type" => type}}}), do: type

  @spec scope_id(Context.t()) :: String.t()
  def scope_id(%Context{event: %{"source" => source}}) do
    do_scope_id(source)
  end

  defp do_scope_id(%{"type" => "user", "user_id" => user_id}), do: user_id
  defp do_scope_id(%{"type" => "group", "group_id" => group_id}), do: group_id
  defp do_scope_id(%{"type" => "room", "room_id" => room_id}), do: room_id
end
