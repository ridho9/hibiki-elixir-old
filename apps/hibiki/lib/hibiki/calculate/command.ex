defmodule Hibiki.Calc.Command do
  use Hibiki.Command
  import Hibiki.Upload, only: [upload_base64_to_catbox: 1]

  def name, do: "calc"

  def description, do: "Calculate query, powered by https://web2.0calc.com/"

  def options,
    do:
      %Options{}
      |> Options.add_named("query", "Query to calculate")
      |> Options.add_flag("i", "Return image instead of text")

  def handle(%{"query" => query, "i" => image}, ctx) do
    case Hibiki.Calc.calculate(query) do
      {:ok, result} ->
        handle_success(query, result, image, ctx)

      {:error, err} ->
        ctx |> add_error(err) |> send_reply()
    end
  end

  defp handle_success(_, %{"img64" => img}, true, ctx) do
    with {:ok, link} <- upload_base64_to_catbox(img) do
      ctx
      |> add_image_message(link)
      |> send_reply()
    end
  end

  defp handle_success(query, %{"out" => out}, false, ctx) do
    ctx
    |> add_text_message("#{query} = #{out}")
    |> send_reply()
  end
end
