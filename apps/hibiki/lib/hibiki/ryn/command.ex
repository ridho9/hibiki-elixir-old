defmodule Hibiki.Ryn.Command do
  use Hibiki.Command
  alias Hibiki.Command.Options

  def name, do: "ryn"
  def description, do: "Answers yes or no."

  def options,
    do:
      %Options{allow_empty_last: true}
      |> Options.add_named("question", "Your question")

  def handle(%{"question" => question}, ctx) do
    answer = Enum.random(["yes", "no", "maybe"])

    ctx
    |> add_text_message("#{question}\n   #{answer}")
    |> send_reply()
  end
end
