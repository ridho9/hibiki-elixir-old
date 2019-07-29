defmodule Hibiki.Command.Code do
  use Hibiki.Command

  def name, do: "code"
  def options, do: %Options{} |> Options.add_named("code") |> Options.add_flag("o")
  def private, do: true

  def handle(%{"code" => code, "o" => o}, ctx) do
    url =
      "https://opener.now.sh/api/data/#{code}"
      |> String.trim()
      |> URI.encode()

    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, result} <- Jason.decode(body),
         %{"title" => title} = result,
         %{"tags" => tags} = result do
      title = title["english"] || title["japanese"]

      artists = get_tags_by_type(tags, "artist")
      languages = get_tags_by_type(tags, "language")
      cat_tags = get_tags_by_type(tags, "tag")
      parodies = get_tags_by_type(tags, "parody")

      message =
        [
          title,
          "Parody: #{parodies}",
          "Tag: #{cat_tags}",
          "Artist: #{artists}",
          "Language: #{languages}"
        ]
        |> Enum.join("\n")

      ctx
      |> add_text_message(message)
      |> (fn x ->
            if not o do
              x
            else
              x |> add_message(create_button_message(code))
            end
          end).()
      |> send_reply()
    end
  end

  defp create_button_message(code) do
    action = %{
      "type" => "uri",
      "label" => "open",
      "uri" => "https://nhentai.net/g/#{code}"
    }

    %{
      "type" => "flex",
      "alt_text" => "Open",
      "contents" => %{
        "type" => "bubble",
        "body" => %{
          "type" => "box",
          "layout" => "vertical",
          "spacing" => "none",
          "margin" => "none",
          "contents" => [
            %{
              "type" => "button",
              "action" => action
            }
          ]
        }
      }
    }
  end

  defp get_tags_by_type(tags, type) do
    res =
      tags
      |> Enum.filter(fn x -> x["type"] == type end)
      |> Enum.map_join(", ", fn x -> x["name"] end)
      |> String.trim()

    if res == "", do: "-", else: res
  end
end
