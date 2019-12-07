defmodule DiceRoll.Eval do
  @max_count 999_999

  def eval(int: [value]) do
    {:ok, value, "#{value}"}
  end

  def eval(simple_dice: [dice_side]) do
    eval(simple_dice: [1, dice_side])
  end

  def eval(simple_dice: [dice_count, _]) when dice_count > @max_count do
    {:error, "dice count cannot be more that #{@max_count}"}
  end

  def eval(simple_dice: [_, dice_side]) when dice_side > @max_count do
    {:error, "dice side cannot be more that #{@max_count}"}
  end

  def eval(simple_dice: [1, dice_side]) do
    result = Enum.random(1..dice_side)

    {:ok, result, "[1d#{dice_side} = #{result}]"}
  end

  def eval(simple_dice: [dice_count, dice_side]) do
    dices =
      if dice_count == 0 do
        []
      else
        1..dice_count
      end
      |> Enum.map(fn _ -> dice_side end)
      |> Enum.map(fn side -> Enum.random(1..side) end)

    result =
      dices
      |> Enum.sum()

    {:ok, result, "[#{dice_count}d#{dice_side} = #{Enum.join(dices, " + ")} = #{result}]"}
  end

  def eval(binary: [value]) do
    eval([value])
  end

  def eval(binary: [first, op | rest]) do
    with {:ok, rest_value, rest_repr} <- eval(binary: rest),
         {:ok, first_value, first_repr} <- eval([first]) do
      binary_op =
        case op do
          "*" -> fn x, y -> x * y end
          "/" -> fn x, y -> x / y end
          "+" -> fn x, y -> x + y end
          "-" -> fn x, y -> x - y end
        end

      result_value = binary_op.(first_value, rest_value)
      result_repr = "#{first_repr} #{op} #{rest_repr}"

      {:ok, result_value, result_repr}
    end
  end
end
