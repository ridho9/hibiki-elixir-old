defmodule Hibiki.Handler do
  @behaviour LineSDK.Handler

  alias Hibiki.Command.Context

  @doc """
  Handle single event from WebhookEvent['events']
  """
  @impl LineSDK.Handler
  def handle(%{"message" => message} = event, opts) do
    ctx =
      %Context{event: event, client: opts[:client]}
      |> Context.start_now()

    opts = Keyword.put(opts, :context, ctx)

    Hibiki.Handler.Message.handle(message, event, opts)
  end

  def handle(_, _) do
    {:error, "unimplemented event handler"}
  end
end

defmodule Hibiki.Handler.Message do
  alias Hibiki.Command.Context
  alias Hibiki.Entity

  @doc """
  Handle message, receives (message, event, opts)
  """
  def handle(
        %{"type" => "text", "text" => text},
        event,
        opts
      ) do
    cache_text_message(text, opts)

    # check regex
    text =
      Regex.run(~r/#([^\n#]+)#/, text)
      |> case do
        [_, tag] -> "!tag - #{tag}"
        _ -> text
      end

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

  defp cache_text_message(text, opts) do
    opts[:context]
    |> Entity.scope_from_context()
    |> Entity.Data.set(Entity.Data.Key.last_text_message(), text)
  end
end

defmodule Hibiki.Handler.Message.Text do
  require Logger

  alias Hibiki.Command.Options
  alias Hibiki.Command.Context
  alias Hibiki.Command.Registry

  def handle(text, _, _) when text == "" or text == nil do
    :ok
  end

  def handle(
        text,
        %{"reply_token" => reply_token},
        opts
      ) do
    ctx = opts[:context]
    client = opts[:client]

    with {:ok, command, args, _} <-
           Registry.command_from_text(Registry.Default.all(), text),
         {:ok, args} <- Options.Parser.parse(command.options, args),
         ctx = Map.put(ctx, :command, command),
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
    hook_command_start(ctx)

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

  def handle(image_id, _event, opts) do
    cache_image_id(image_id, opts)
    :ok
  end

  defp cache_image_id(image_id, opts) do
    opts[:context]
    |> Entity.scope_from_context()
    |> Entity.Data.set(Entity.Data.Key.last_image_id(), image_id)
  end
end
