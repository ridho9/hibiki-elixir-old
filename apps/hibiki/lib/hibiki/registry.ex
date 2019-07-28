defmodule Hibiki.Registry do
  defmodule Default do
    alias Hibiki.Command, as: Command
    def all, do: [Command.Calc, Command.Call, Command.Chs, Command.Help, Command.Code]
  end

  def command_from_text(_, ""), do: {:error, "no command"}
  def command_from_text(_, nil), do: {:error, "no command"}
  def command_from_text(registry, input), do: command_from_text(registry, input, [])

  def command_from_text(registry, input, parent) do
    [head | rest] = input |> String.trim() |> String.split(" ", parts: 2)

    case Enum.find(registry, fn x -> x.name() == head end) do
      nil ->
        {:error, "can't find command '#{head}'"}

      command ->
        rest =
          case rest do
            [] -> ""
            [rest] -> String.trim(rest)
          end

        case command_from_text(command.subcommands, rest, parent ++ [command]) do
          {:error, _} -> {:ok, command, rest, parent}
          result -> result
        end
    end
  end
end
