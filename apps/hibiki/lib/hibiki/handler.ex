defmodule Hibiki.Handler do
  @behaviour LineSDK.Handler

  @doc """
  Handle single event from WebhookEvent['events']
  """
  def handle(%{"message" => message} = event, opts) do
    IO.inspect(event)
    IO.inspect(opts)
    handle_message(message, event, opts)
  end

  @doc """
  Handle message, receives (message, event, opts)
  """
  def handle_message(
        %{"type" => "text", "text" => text},
        %{"reply_token" => reply_token},
        opts
      ) do
    LineSDK.Client.send_reply(opts[:client], reply_token, %{"type" => "text", "text" => text})
  end

  def handle_message(message, _reply_token, _opts) do
    {:error, message}
  end
end
