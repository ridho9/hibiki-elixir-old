defmodule Hibiki.Case.Command do
  use Hibiki.Command
  alias Hibiki.Command.Options

  def name, do: "case"

  def description, do: "Various string case transformation"

  def options,
    do:
      %Options{}
      |> Options.add_named("query", "Thing to be transformed")
      |> Options.add_flag("u", "To uppercase")
      |> Options.add_flag("l", "To lowercase")
      |> Options.add_flag("c", "Capitalize")
      |> Options.add_flag("m", "Mixed case")

  def handle(%{"query" => query, "u" => u, "l" => l, "c" => c, "m" => m}, ctx) do
    result =
      cond do
        m ->
          query
          |> String.codepoints()
          |> Enum.map_every(2, fn x -> String.upcase(x) end)
          |> Enum.join()

        u ->
          String.upcase(query)

        l ->
          String.downcase(query)

        c ->
          String.capitalize(query)

        true ->
          query
      end

    ctx
    |> add_text_message(result)
    |> send_reply()
  end
end
