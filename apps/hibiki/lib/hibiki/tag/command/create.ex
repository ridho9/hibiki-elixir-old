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
      |> Options.add_flag("t", "create text tag")
      |> Options.add_flag("!")

  def pre_handle(args, ctx) do
    with {:ok, args, ctx} <- Hibiki.Tag.Command.pre_handle_check_added(args, ctx),
         {:ok, args, ctx} <- Hibiki.Tag.Command.pre_handle_load_scope(args, ctx) do
      do_pre_handle_global(args, ctx)
    end
  end

  def handle(
        %{"name" => name, "value" => value, "user" => user, "scope" => scope, "t" => text},
        ctx
      ) do
    tag_type = if text, do: "text", else: "image"
    name = String.downcase(name)

    case Hibiki.Tag.create(name, tag_type, value, user, scope) do
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

  defp do_pre_handle_global(%{"!" => true} = args, ctx) do
    Hibiki.Tag.Command.pre_handle_global_scope(args, ctx)
  end

  defp do_pre_handle_global(%{"!" => false} = args, ctx) do
    {:ok, args, ctx}
  end
end
