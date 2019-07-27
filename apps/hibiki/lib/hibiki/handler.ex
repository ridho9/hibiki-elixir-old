defmodule Hibiki.Handler do
  require Logger

  alias Hibiki.Registry
  alias Hibiki.Command.Options
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
    with {:ok, command, args, _} <-
           Registry.command_from_text(Registry.Default.all(), text),
         {:ok, args} <- Options.parse(command.options, args),
         ctx = %Context{
           client: client,
           event: event,
           command: command
         },
         {:ok, _} <- call_command_handler(command, args, ctx) do
      {:ok}
    else
      {:error, message} = err ->
        LineSDK.Client.send_reply(client, reply_token, %{
          "type" => "text",
          "text" => "Ugh.. #{message}"
        })

        err
    end
  end

  def call_command_handler(command, args, ctx) do
    token = ctx.event["reply_token"] |> String.slice(-6..-1)
    Logger.metadata(token: token, args: args, ctx: ctx)
    Logger.debug("start handle #{command}")

    result =
      case command.handle(args, ctx) do
        {:error, err} = result ->
          Logger.error(err)
          result

        result ->
          {:ok, result}
      end

    Logger.debug("end handle #{command}")
    Logger.metadata(token: nil, args: nil, ctx: nil)

    result
  end
end
