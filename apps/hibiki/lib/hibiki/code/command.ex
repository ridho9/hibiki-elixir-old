defmodule Hibiki.Code.Command do
  use Hibiki.Command

  def name, do: "code"

  def options,
    do:
      %Options{}
      |> Options.add_named("code", "Code to search")
      |> Options.add_flag("o", "Add open button")

  def private, do: true

  def handle(%{"code" => code} = args, ctx) do
    code = URI.encode_www_form(code)

    url =
      "https://opener.now.sh/api/data/#{code}"
      |> String.trim()
      |> URI.encode()

    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url, follow_redirect: true),
         {:ok, result} <- Jason.decode(body) do
      handle_result(args, result, ctx)
    end
  end

  defp handle_result(%{"code" => code, "o" => o}, %{"success" => true} = result, ctx) do
    %{"title" => title, "tags" => tags} = result
    title = title["english"] || title["japanese"]

    artists = get_tags_by_type(tags, "artist")
    languages = get_tags_by_type(tags, "language")
    cat_tags = get_tags_by_type(tags, "tag")
    parodies = get_tags_by_type(tags, "parody")

    message =
      [
        "[#{code}]" <> title,
        "Parody: #{parodies}",
        "Tag: #{cat_tags}",
        "Artist: #{artists}",
        "Language: #{languages}"
      ]
      |> Enum.join("\n")

    ctx
    |> add_text_message(message)
    |> (fn x ->
          if o do
            x |> add_message(create_button_message(code))
          else
            x
          end
        end).()
    |> send_reply()
  end

  defp handle_result(_, %{"success" => false} = result, ctx) do
    ctx
    |> add_error(result["description"])
    |> send_reply()
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
