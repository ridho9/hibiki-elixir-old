defmodule Hibiki.Calc.Command do
  use Hibiki.Command
  import Hibiki.Upload.Lib, only: [upload_base64_to_catbox: 1]

  def name, do: "calc"

  def description, do: "Calculate query, powered by https://web2.0calc.com/"

  def options,
    do:
      %Options{}
      |> Options.add_named("query", "Query to calculate")
      |> Options.add_flag("i", "Return image instead of text")

  def handle(%{"query" => query, "i" => image}, ctx) do
    case send_query(query) do
      {:ok, result} ->
        handle_success(query, result, image, ctx)

      {:error, err} ->
        ctx |> add_error(err) |> send_reply()
    end
  end

  def handle_success(_, %{"img64" => img}, true, ctx) do
    with {:ok, link} <- upload_base64_to_catbox(img) do
      ctx
      |> add_image_message(link)
      |> send_reply()
    end
  end

  def handle_success(query, %{"out" => out}, false, ctx) do
    ctx
    |> add_text_message("#{query} = #{out}")
    |> send_reply()
  end

  def send_query(query) do
    data = [trig: "deg", s: 0, p: 0, "in[]": query]

    url = "https://web2.0calc.com/calc"
    headers = []

    with data = {:form, data},
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(url, data, headers),
         {:ok, %{"results" => result}} <- Jason.decode(body),
         result = hd(result),
         %{"status" => status} = result do
      if status == "ok" do
        {:ok, result}
      else
        {:error, status}
      end
    end
  end
end
