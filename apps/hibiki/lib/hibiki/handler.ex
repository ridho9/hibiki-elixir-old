defmodule Hibiki.Handler do
  require Logger

  alias Hibiki.Registry
  alias Hibiki.Command
  alias Hibiki.Context

  @behaviour LineSDK.Handler

  @doc """
  Handle single event from WebhookEvent['events']
  """
  @impl LineSDK.Handler
  def handle(%{"message" => message} = event, opts) do
    handle_message(message, event, opts)
  end

  @doc """
  Handle message, receives (message, event, opts)
  """
  def handle_message(
        %{"type" => "text", "text" => text},
        event,
        opts
      ) do
    if String.starts_with?(text, "!") do
      {_, text} = text |> String.split_at(1)
      handle_text_message(text, event, opts)
    end
  end

  def handle_message(_message, _reply_token, _opts) do
    # {:error, message}
  end

  def handle_text_message(
        text,
        %{"reply_token" => reply_token} = event,
        client: client
      ) do
    with {:ok, command, args} <-
           Registry.command_from_text(Registry.Default.all(), text),
         {:ok, args, rest_arg} <- command.options() |> Command.Options.parse(args),
         ctx = %Context{client: client, event: event, rest_arg: rest_arg, command: command},
         {:ok} <- call_command_handler(command, args, ctx) do
      {:ok}
    else
      {:error, message} = err ->
        LineSDK.Client.send_reply(client, reply_token, %{type: "text", text: "Ugh.. #{message}"})
        err
    end
  end

  def call_command_handler(command, args, ctx) do
    command.handle(args, ctx)
  end
end
