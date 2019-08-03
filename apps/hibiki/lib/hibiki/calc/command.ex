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
    with {:ok, %{"results" => result}} <- calculate_query(query), result = result |> hd do
      if image do
        with %{"img64" => binary} = result,
             {:ok, link} <- upload_base64_to_catbox(binary) do
          ctx |> add_image_message(link) |> send_reply()
        end
      else
        %{"out" => result} = result
        ctx |> add_text_message("#{query} = #{result}") |> send_reply()
      end
    end
  end

  def calculate_query(query) do
    data = [trig: "deg", s: 0, p: 0, "in[]": query]

    url = "https://web2.0calc.com/calc"
    headers = []

    with data = {:form, data},
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(url, data, headers),
         result <- Jason.decode(body) do
      result
    end
  end
end
