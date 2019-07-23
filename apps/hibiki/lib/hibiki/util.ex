defmodule Hibiki.Util do
  def next_token(nil), do: {:error, "empty input"}
  def next_token(""), do: {:error, "empty input"}

  def next_token(input) do
    input = String.trim_leading(input)
    regex = ~r{`[^`]*`|'[^']*'|"[^"]*"|\S+}u

    case Regex.run(regex, input, capture: :first) do
      nil ->
        {:error, "no match"}

      [head | _] ->
        {_, rest} = String.split_at(input, String.length(head))
        rest = String.trim_leading(rest)

        first_char = String.at(head, 0)

        head =
          if first_char == "\"" || first_char == "'" || first_char == "`" do
            String.slice(head, 1..-2)
          else
            head
          end

        {:ok, head, rest}
    end
  end
end
