defmodule Hibiki.Registry do
  defmodule Default do
    alias Hibiki.Command, as: Command
    def all, do: [Command.Call]
  end

  def command_from_text(_, ""), do: {:error, "empty input"}
  def command_from_text(_, nil), do: {:error, "empty input"}

  def command_from_text(registry, input) do
    [head | rest] = input |> String.trim() |> String.split(" ", parts: 2)

    case Enum.find(registry, fn x -> x.name() == head end) do
      nil ->
        {:error, "no command found"}

      command ->
        rest =
          case rest do
            [] -> nil
            [rest] -> String.trim(rest)
          end

        case command_from_text(command.subcommands, rest) do
          {:error, _} -> {:ok, command, rest}
          {:ok, sc, sr} -> {:ok, sc, sr}
        end
    end
  end
end
