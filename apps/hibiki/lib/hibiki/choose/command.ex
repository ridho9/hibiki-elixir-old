defmodule Hibiki.Choose.Command do
  use Hibiki.Command

  def name, do: "chs"
  def description, do: "Choose!"

  def options,
    do: %Options{} |> Options.add_named("choice", "Choices to select separated by space")

  def handle(%{"choice" => choice}, ctx) do
    result =
      choice
      |> Hibiki.Parser.tokenize()
      |> Enum.random()

    ctx
    |> add_text_message("I choose #{result}")
    |> send_reply()
  end
end
