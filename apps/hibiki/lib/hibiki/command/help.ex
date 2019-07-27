defmodule Hibiki.Command.Help do
  use Hibiki.Command
  alias Hibiki.Registry

  def name, do: "help"

  def description, do: "When you don't know what things do"

  def options, do: %Options{allow_empty_last: true} |> Options.add_named("query", "query")

  def handle(args, ctx) do
    query = args["query"]

    handle_query(query, ctx)
  end

  def handle_query("", ctx) do
    command_list =
      Registry.Default.all()
      |> Enum.filter(fn x -> x.private() == false end)
      |> Enum.map(fn x -> x.name() end)
      |> Enum.join(", ")

    ctx
    |> add_text_message(
      "Commands list: #{command_list}\n\nUse '!help <command>' for more details"
    )
    |> send_reply()
  end

  def handle_query(query, ctx) do
    query = String.trim(query)

    case Registry.command_from_text(Registry.Default.all(), query) do
      {:ok, command, _, parent} ->
        commands =
          (parent ++ [command])
          |> Enum.map(fn x -> x.name end)
          |> Enum.join(" ")

        usage_line = Options.generate_usage_line(command.options)

        help_string =
          ("Usage: !#{commands} #{usage_line}\n\n" <> "#{command.description()}")
          |> String.trim()

        ctx |> add_text_message(help_string) |> send_reply()

      {:error, _} ->
        {:error, "Can't find help for '#{query}'"}
    end
  end
end
