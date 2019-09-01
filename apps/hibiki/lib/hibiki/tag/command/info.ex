defmodule Hibiki.Tag.Command.Info do
  use Hibiki.Command
  alias Hibiki.Command.Options
  alias Hibiki.Tag

  def name, do: "info"

  def descriptions, do: "gets info about a tag"

  def options, do: %Options{} |> Options.add_named("name", "tag name")

  def pre_handle(args, ctx) do
    with {:ok, args, ctx} <- Hibiki.Tag.Command.pre_handle_check_added(args, ctx) do
      Hibiki.Tag.Command.pre_handle_load_scope(args, ctx)
    end
  end

  def handle(%{"name" => name, "scope" => scope, "user" => user}, ctx) do
    case Tag.get_from_tiered_scope(name, scope, user) do
      nil ->
        ctx
        |> add_error("Can't find tag '#{name}' in this #{scope.type}")

      tag ->
        tag
        |> Hibiki.Repo.preload([:creator, :scope])
        |> handle_tag(ctx)
    end
  end

  defp handle_tag(tag, ctx) do
    creator = tag.creator

    with {:ok, creator_info} <- LineSDK.Client.get_profile(ctx.client, creator.line_id) do
      IO.inspect(creator_info)

      msg =
        [
          "[ #{tag.name} ]",
          "Created by: #{creator_info["displayName"]}",
          "Type: #{tag.type}",
          "Scope: #{tag.scope.type}",
          "#{tag.id}:#{tag.creator.id}:#{tag.scope.id}"
        ]
        |> Enum.filter(fn x -> x != nil end)
        |> Enum.join("\n")

      ctx
      |> add_text_message(msg)
      |> send_reply()
    end
  end
end
