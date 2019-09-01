defmodule Hibiki.Tag.Command.Delete do
  use Hibiki.Command
  alias Hibiki.Command.Options
  alias Hibiki.Tag

  def name, do: "delete"

  def description, do: "Deletes tag"

  def options,
    do:
      %Options{}
      |> Options.add_flag("!")
      |> Options.add_named("name", "tag name")

  def pre_handle(args, ctx), do: Tag.Command.Create.pre_handle(args, ctx)

  def handle(%{"name" => name, "scope" => scope}, ctx) do
    Tag.by_name(name, scope)
    |> do_handle(name, scope, ctx)
  end

  def do_handle(nil, name, scope, ctx) do
    ctx
    |> add_error("Can't find tag '#{name}' in this #{scope.type}")
    |> send_reply()
  end

  def do_handle(tag, name, _, ctx) when tag != nil do
    case Tag.delete(tag) do
      {:ok, _} ->
        ctx
        |> add_text_message("Successfully deleted tag '#{name}'")
        |> send_reply()

      {:error, changeset} ->
        err = "Error deleting tag: " <> Tag.format_error(changeset)

        ctx
        |> add_error(err)
        |> send_reply()
    end
  end
end
