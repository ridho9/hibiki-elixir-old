defmodule Hibiki.Tag.Command do
  use Hibiki.Command
  alias Hibiki.Entity
  alias Hibiki.Tag
  import Hibiki.Command.Context.Source

  def name, do: "tag"
  def description, do: "Get tag <name>"
  def options, do: %Options{} |> Options.add_named("name", "tag name")

  def pre_handle(args, ctx) do
    user_id = user_id(ctx)
    user = Entity.create_or_get(user_id, "user")

    scope_id = scope_id(ctx)
    scope_type = scope_type(ctx)
    scope = Entity.create_or_get(scope_id, scope_type)

    args =
      args
      |> Map.put("user", user)
      |> Map.put("scope", scope)

    {:ok, args, ctx}
  end

  def handle(%{"name" => name} = args, ctx) do
    IO.inspect(args)
    ctx
  end

  def subcommands,
    do: [
      Tag.Command.Create,
      Tag.Command.List
    ]
end

defmodule Hibiki.Tag.Command.Create do
  use Hibiki.Command
  alias Hibiki.Command.Options

  def name, do: "create"
  def description, do: "Creates a new tag"

  def options,
    do:
      %Options{}
      |> Options.add_named("name", "tag name")
      |> Options.add_named("value", "tag value")
      |> Options.add_flag("!")

  def pre_handle(args, ctx) do
    with {:ok, args, ctx} <- Hibiki.Tag.Command.pre_handle(args, ctx) do
      # check for user to be registered
      if args["!"] do
        if Hibiki.Entity.admin?(args["user"]) do
          args = %{args | "scope" => Hibiki.Entity.global()}
          {:ok, args, ctx}
        else
          ctx = ctx |> add_error("You are not an admin") |> send_reply()
          {:stop, ctx}
        end
      else
        {:ok, args, ctx}
      end
    end
  end

  def handle(%{"name" => name, "value" => value, "user" => user, "scope" => scope}, ctx) do
    case Hibiki.Tag.create(name, "image", value, user, scope) do
      {:ok, tag} ->
        ctx
        |> add_text_message("Successfully created tag '#{tag.name}' in this #{scope.type}")
        |> send_reply()

      {:error, err} ->
        err = "Error creating tag '#{name}': " <> Hibiki.Tag.Schema.format_error(err)

        ctx
        |> add_error(err)
        |> send_reply()
    end
  end
end

defmodule Hibiki.Tag.Command.List do
  use Hibiki.Command

  def name, do: "list"
  def description, do: "Lists available tags"

  def pre_handle(args, ctx) do
    Hibiki.Tag.Command.pre_handle(args, ctx)
  end

  def handle(%{"user" => user, "scope" => scope}, ctx) do
    global_tags = "Global: " <> list_tag_in_scope(Hibiki.Entity.global())
    user_tags = "User: " <> list_tag_in_scope(user)

    result = [user_tags, global_tags]

    result =
      if scope.type in ["group", "room"] do
        scope_tags = String.capitalize(scope.type) <> ": " <> list_tag_in_scope(scope)
        [scope_tags] ++ result
      else
        result
      end

    result =
      result
      |> Enum.filter(fn x -> x != nil or x != "" end)
      |> Enum.join("\n")

    ctx
    |> add_text_message(result)
    |> send_reply()
  end

  defp list_tag_in_scope(scope) do
    scope
    |> Hibiki.Tag.get_by_scope()
    |> Enum.map(fn x -> x.name end)
    |> Enum.join(", ")
    |> case do
      "" -> "no tag found"
      x -> x
    end
  end
end
