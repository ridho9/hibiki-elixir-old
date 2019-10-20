defmodule Hibiki.Tag.Command.List do
  use Hibiki.Command
  alias Hibiki.Command.Options

  def name, do: "list"
  def description, do: "Lists available tags"

  def options,
    do:
      %Options{allow_empty_last: true}
      |> Options.add_named("keyword", "keyword to filter")

  def pre_handle(args, ctx) do
    Hibiki.Tag.Command.pre_handle_load_scope(args, ctx)
  end

  def handle(%{"user" => user, "scope" => scope, "keyword" => keyword}, ctx) do
    user_tags = "User: " <> list_tag_in_scope(user, keyword)
    global_tags = "Global: " <> list_tag_in_scope(Hibiki.Entity.global(), keyword)

    scope_tags =
      if scope.type in ["group", "room"] do
        String.capitalize(scope.type) <> ": " <> list_tag_in_scope(scope, keyword)
      end

    result = [
      user_tags,
      scope_tags,
      global_tags
    ]

    result =
      result
      |> Enum.filter(fn x -> x != nil and x != "" end)
      |> Enum.join("\n\n")

    ctx
    |> add_text_message(result)
    |> send_reply()
  end

  defp list_tag_in_scope(scope, keyword \\ "") do
    scope
    |> Hibiki.Tag.get_by_scope()
    |> Enum.map(fn x -> x.name end)
    |> Enum.filter(fn s -> String.contains?(s, keyword) end)
    |> Enum.sort()
    |> Enum.join(", ")
    |> case do
      "" -> "no tag found"
      x -> x
    end
  end
end
