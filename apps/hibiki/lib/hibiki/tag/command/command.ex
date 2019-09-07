defmodule Hibiki.Tag.Command do
  use Hibiki.Command

  alias Hibiki.Entity
  alias Hibiki.Tag
  alias Hibiki.Command.Options
  alias Hibiki.Command.Context.Source

  def name, do: "tag"
  def description, do: "Get tag <name>"

  def options,
    do:
      %Options{}
      |> Options.add_named("name", "tag name")

  def pre_handle(args, ctx) do
    pre_handle_load_scope(args, ctx)
  end

  def pre_handle_load_scope(args, ctx) do
    user_id = Source.user_id(ctx)
    user = Entity.create_or_get(user_id, "user")

    scope_id = Source.scope_id(ctx)
    scope_type = Source.scope_type(ctx)
    scope = Entity.create_or_get(scope_id, scope_type)

    args =
      args
      |> Map.put("user", user)
      |> Map.put("scope", scope)

    {:ok, args, ctx}
  end

  def pre_handle_global_scope(args, ctx) do
    if Hibiki.Entity.admin?(args["user"]) do
      args = Map.put(args, "scope", Hibiki.Entity.global())
      {:ok, args, ctx}
    else
      ctx =
        ctx
        |> add_error("You are not an admin")
        |> send_reply()

      {:stop, ctx}
    end
  end

  def pre_handle_check_added(args, ctx) do
    user_id = Source.user_id(ctx)

    case LineSDK.Client.get_profile(ctx.client, user_id) do
      {:ok, _} ->
        {:ok, args, ctx}

      {:error, _} ->
        ctx =
          ctx
          |> add_error("Please add Hibiki first")
          |> send_reply()

        {:stop, ctx}
    end
  end

  def handle(%{"name" => name, "scope" => scope, "user" => user}, ctx) do
    case Tag.get_from_tiered_scope(name, scope, user) do
      nil -> handle_tag_nil(name, scope, ctx)
      tag -> handle_tag(tag, tag.type, ctx)
    end
  end

  def subcommands,
    do: [
      Tag.Command.Create,
      Tag.Command.List,
      Tag.Command.Delete,
      Tag.Command.Info
    ]

  defp handle_tag(tag, "image", ctx) do
    ctx
    |> add_image_message(tag.value)
    |> send_reply()
  end

  defp handle_tag(tag, "text", ctx) do
    ctx
    |> add_text_message(tag.value)
    |> send_reply()
  end

  defp handle_tag_nil(name, scope, ctx) do
    ctx
    |> add_error("Tag '#{name}' not found in this #{scope.type}")
    |> send_reply()
  end
end
