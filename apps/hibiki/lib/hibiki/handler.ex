defmodule Hibiki.Handler do
  @behaviour LineSDK.Handler

  @doc """
  Handle single event from WebhookEvent['events']
  """
  def handle(%{"message" => message} = event, opts) do
    handle_message(message, event, opts)
  end

  def handle_message(
        %{"type" => "text", "text" => text},
        %{"replyToken" => reply_token},
        opts
      ) do
    LineSDK.Client.send_reply(opts.client, reply_token, %{"type" => "text", "text" => text})
  end

  def handle_message(message, _reply_token, _opts) do
    {:error, message}
  end
end
