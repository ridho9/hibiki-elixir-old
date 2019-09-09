defmodule DiceRoll do
  @spec roll(String.t()) :: {:error, String.t()} | {:ok, number, String.t()}
  def roll(expression) do
    expression = String.trim(expression)

    with {:ok, tree, _rest, _, _, _} <- DiceRoll.Parser.parse(expression) do
      DiceRoll.Eval.eval(tree)
    else
      {:error, err} ->
        {:error, err}

      {:error, _, rest, _, _, _} ->
        {:error, "error parsing expression in part before '#{rest}'"}
    end
  end
end
