defmodule Hibiki.Roll.Command do
  use Hibiki.Command

  def name, do: "roll"

  def description,
    do:
      "Do a dnd roll, syntax from https://wiki.roll20.net/Dice_Reference#Roll20_Dice_Specification"

  def options,
    do:
      %Options{}
      |> Options.add_named("query", "Roll query")

  def handle(%{"query" => query}, ctx) do
    case DiceRoll.roll(query) do
      {:ok, res_val, res_repr} ->
        ctx
        |> add_text_message("#{query}\n= #{res_repr} = #{res_val}")
        |> send_reply()

      {:error, err} ->
        ctx
        |> add_error(err)
        |> send_reply()
    end
  end
end
