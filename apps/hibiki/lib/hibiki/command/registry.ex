defmodule Hibiki.Command.Registry do
  defmodule Default do
    alias Hibiki, as: H

    def all,
      do: [
        H.Info.Command,
        H.Calc.Command,
        H.Call.Command,
        H.Choose.Command,
        H.Help.Command,
        H.Code.Command,
        H.Tag.Command,
        H.Ryn.Command,
        H.Upload.Command,
        H.Roll.Command,
        H.Case.Command,
        # H.History.Command,
        H.Sauce.Command,
        H.Meme.Command
      ]
  end

  def command_from_text(_, ""), do: {:error, "no command"}
  def command_from_text(_, nil), do: {:error, "no command"}
  def command_from_text(registry, input), do: command_from_text(registry, input, [])

  def command_from_text(registry, input, parent) do
    [head | rest] =
      input
      |> String.trim()
      |> String.split(" ", parts: 2)

    case Enum.find(registry, fn x -> x.name() == head end) do
      nil ->
        {:error, "can't find command '#{head}'"}

      command ->
        rest =
          case rest do
            [] -> ""
            [rest] -> String.trim(rest)
          end

        subparent = parent ++ [command]

        case command_from_text(command.subcommands, rest, subparent) do
          {:error, _} -> {:ok, command, rest, parent}
          result -> result
        end
    end
  end
end
