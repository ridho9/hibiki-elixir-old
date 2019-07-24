defmodule Hibiki.Command.Call do
  use Hibiki.Command

  def name, do: "call"

  def description, do: "A simple call"

  def handle(_args, ctx) do
    ctx
    |> add_text_message("Roger, Hibiki, heading out!\n\nI'll never forget Tenshi...")
    |> send_reply()
  end
end
