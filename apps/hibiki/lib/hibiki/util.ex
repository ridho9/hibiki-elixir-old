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
        rest =
          input
          |> String.split_at(String.length(head))
          |> elem(1)
          |> String.trim_leading()

        head =
          if String.at(head, 0) in ["\"", "'", "`"] do
            String.slice(head, 1..-2)
          else
            head
          end

        {:ok, head, rest}
    end
  end

  def tokenize(nil), do: []
  def tokenize(input), do: tokenize(input, [])

  defp tokenize(input, acc) do
    case next_token(input) do
      {:ok, token, rest} ->
        tokenize(rest, acc ++ [token])

      {:error, _} ->
        acc
    end
  end
end
