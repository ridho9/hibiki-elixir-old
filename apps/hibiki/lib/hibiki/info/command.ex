defmodule Hibiki.Info.Command do
  use Hibiki.Command

  def name, do: "info"

  def handle(_, ctx) do
    ctx
    |> add_text_message(~s"""
    [Hibiki]

    Made by Ridho Pratama & Gabriel B. Raphael.
    Powered by Elixir.
    """)
    |> send_reply()
  end
end
