defmodule Hibiki.Handler do
  @behaviour LineSDK.Handler

  @doc """
  Handle single event from WebhookEvent['events']
  """
  @impl LineSDK.Handler
  def handle(%{"message" => message} = event, opts) do
    Hibiki.Handler.Message.handle(message, event, opts)
  end

  def handle(_, _) do
    {:error, "unimplemented event handler"}
  end
end

defmodule Hibiki.Handler.Message do
  @doc """
  Handle message, receives (message, event, opts)
  """
  def handle(
        %{"type" => "text", "text" => text},
        event,
        opts
      ) do
    text
    |> String.trim()
    |> String.starts_with?("!")
    |> if do
      {_, text} = String.split_at(text, 1)
      Hibiki.Handler.Message.Text.handle(text, event, opts)
    end
  end

  def handle(%{"type" => "image", "id" => image_id}, event, opts) do
    Hibiki.Handler.Message.Image.handle(image_id, event, opts)
  end

  def handle(_, _, _) do
    {:error, "unimplemented handle message"}
  end
end

defmodule Hibiki.Handler.Message.Text do
  require Logger

  alias Hibiki.Command.Options
  alias Hibiki.Command.Context
  alias Hibiki.Command.Registry

  def handle(
        text,
        %{"reply_token" => reply_token} = event,
        client: client
      ) do
    with {:ok, command, args, _} <-
           Registry.command_from_text(Registry.Default.all(), text),
         {:ok, args} <- Options.Parser.parse(command.options, args),
         ctx = %Context{
           client: client,
           event: event,
           command: command
         },
         {:ok, _} <- call_command_handler(command, args, ctx) do
      :ok
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
    ctx =
      ctx
      |> Context.start_now()
      |> hook_command_start()

    result =
      with {:ok, args, ctx} <- command.pre_handle(args, ctx),
           result when is_map(result) <- command.handle(args, ctx) do
        {:ok, result}
      else
        {:error, err} ->
          Logger.error(err)
          {:error, err}

        {:stop, _} ->
          {:ok, "prehandle stop"}
      end

    hook_command_end(ctx)
    result
  end

  def hook_command_start(ctx) do
    token = ctx.event["reply_token"] |> String.slice(-6..-1)

    Logger.metadata(token: token, args: ctx.args, ctx: ctx, command: ctx.command)
    Logger.debug("start handle #{ctx.command}")

    ctx
  end

  def hook_command_end(ctx) do
    time_diff = DateTime.diff(DateTime.utc_now(), ctx.start_time, :millisecond)

    Logger.debug("end handle #{ctx.command} in #{time_diff}ms", time: time_diff)
    Logger.metadata(token: nil, args: nil, ctx: nil, command: nil)

    ctx
  end
end

defmodule Hibiki.Handler.Message.Image do
  alias Hibiki.Command.Context
  alias Hibiki.Command.Context.Source
  alias Hibiki.Entity

  @spec handle(String.t(), map, client: LineSDK.Client.t()) :: :ok | {:error, any}
  def handle(image_id, event, client: client) do
    %Context{event: event, client: client}
    |> Context.start_now()
    |> Entity.scope_from_context()
    |> Entity.Data.set(:last_image_id, image_id)
  end
end
