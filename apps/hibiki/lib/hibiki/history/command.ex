defmodule Hibiki.History.Command do
  use Hibiki.Command
  alias Hibiki.Entity

  def name, do: "history"

  def description, do: "A simple call"

  def private, do: true

  def handle(_args, ctx) do
    text_history =
      ctx
      |> Entity.scope_from_context()
      |> Entity.Data.get(Entity.Data.Key.text_history())
      |> Enum.map(fn {msg, _src} ->
        max_length = 40

        msg =
          if String.length(msg) < max_length do
            msg
          else
            String.slice(msg, 0, max_length) <> "..."
          end

        "> #{msg}"
      end)
      |> Enum.join("\n")

    ctx
    |> add_text_message(text_history)
    |> send_reply()
  end
end
