defmodule Hibiki.Meme.Command do
  use Hibiki.Command

  def name, do: "meme"

  def description, do: "Create memes, powered by https://imgflip.com/"

  def options,
    do:
      %Options{}
      |> Options.add_named(
        "template",
        "Template id, look at https://api.imgflip.com/popular_meme_ids for inspiration"
      )
      |> Options.add_named("text0", "text 0")
      |> Options.add_named("text1", "text 1")

  def handle(%{"template" => template, "text0" => text0, "text1" => text1}, ctx) do
    case Hibiki.Meme.generate(template, text0, text1) do
      {:ok, result} ->
        ctx |> add_image_message(result) |> send_reply()

      {:error, err} ->
        ctx |> add_error(err) |> send_reply()
    end
  end
end
