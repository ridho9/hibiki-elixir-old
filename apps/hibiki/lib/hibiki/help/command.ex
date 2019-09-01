defmodule Hibiki.Help.Command do
  use Hibiki.Command
  alias Hibiki.Command.Registry

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
      |> Enum.sort()
      |> Enum.join(", ")

    ctx
    |> add_text_message(
      [
        "Commands list: #{command_list}",
        "Use '!help <command>' for more details",
        "Topics list: command",
        "Use '!help <topic>' for topic explanation"
      ]
      |> Enum.join("\n")
    )
    |> send_reply()
  end

  def handle_query("command", ctx) do
    ctx
    |> add_text_message(~s"""
    Command system
    """)
    |> send_reply()
  end

  def handle_query(query, ctx) do
    query = String.trim(query)

    case Registry.command_from_text(Registry.Default.all(), query) do
      {:error, _} ->
        ctx
        |> add_error("Can't find help for '#{query}'")
        |> send_reply()

      {:ok, command, _, parent} ->
        commands =
          (parent ++ [command])
          |> Enum.map(fn x -> x.name end)
          |> Enum.join(" ")

        usage_line = Options.Describe.generate_usage_line(command.options)
        usage_desc = Options.Describe.generate_usage_description(command.options)

        help_string =
          [
            "Usage: !#{commands} #{usage_line}",
            "#{command.description()}",
            usage_desc,
            if length(command.subcommands) > 0 do
              subcommand_names =
                command.subcommands
                |> Enum.map(fn x -> x.name end)
                |> Enum.sort()
                |> Enum.join(", ")

              "Subcommands: #{subcommand_names}\nUse '!help #{commands} <subcommand>' for more info"
            end
          ]
          |> Enum.filter(fn x -> x != nil end)
          |> Enum.filter(fn x -> String.trim(x) != "" end)
          |> Enum.join("\n\n")
          |> String.trim()

        ctx |> add_text_message(help_string) |> send_reply()
    end
  end
end
