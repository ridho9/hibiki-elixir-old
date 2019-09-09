defmodule DiceRoll.Parser.Helper do
  import NimbleParsec

  def literal do
    ignore_whitespace()
    |> choice([
      simple_dice(),
      integer_literal()
    ])
    |> optional(ignore_whitespace())
  end

  def integer_literal do
    integer(min: 1)
    |> tag(:int)
  end

  def simple_dice do
    optional(integer(min: 1))
    |> ignore(string("d"))
    |> integer(min: 1)
    |> label("simple dice like 'd6' '2d20'")
    |> tag(:simple_dice)
  end

  def ignore_whitespace do
    ignore(
      repeat(
        choice([
          string(" "),
          string("\n"),
          string("\t")
        ])
      )
    )
  end
end

defmodule DiceRoll.Parser do
  import NimbleParsec
  import DiceRoll.Parser.Helper

  primary =
    choice([
      parsec(:group),
      literal()
    ])

  multiplication =
    primary
    |> concat(
      repeat(
        choice([
          string("*"),
          string("/")
        ])
        |> concat(primary)
      )
    )
    |> tag(:binary)

  addition =
    multiplication
    |> concat(
      repeat(
        choice([
          string("+"),
          string("-")
        ])
        |> concat(multiplication)
      )
    )
    |> tag(:binary)

  expr = addition

  defcombinatorp(
    :expression,
    expr
    |> eos()
  )

  defcombinatorp(
    :group,
    ignore(string("("))
    |> parsec(:expression)
    |> ignore(string(")"))
    |> tag(:group)
  )

  defparsec(:parse, parsec(:expression))
end
