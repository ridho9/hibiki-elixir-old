defmodule Hibiki.Command.Options do
  defstruct named: %{}, named_key: [], flag: %{}, optional: %{}, allow_empty_last: false

  import Hibiki.Util, only: [next_token: 1]
  alias Hibiki.Command.Options

  def generate_usage_line(%Options{
        flag: flag,
        optional: optional,
        named_key: named_key,
        allow_empty_last: allow_empty_last
      }) do
    flag_line = if Enum.empty?(flag), do: "", else: "[..flags] "
    optional_line = if Enum.empty?(optional), do: "", else: "[..optionals] "

    last_key = List.last(named_key)

    named_line =
      named_key
      |> Enum.map(fn
        key when key == last_key and allow_empty_last -> "[#{key}]"
        key -> "<#{key}>"
      end)
      |> Enum.join(" ")

    "#{flag_line}#{optional_line}#{named_line}" |> String.trim()
  end

  def fill_defaults(%Options{flag: flag, optional: optional}) do
    default_flag =
      flag
      |> Enum.reduce(%{}, fn {key, _}, acc -> Map.put(acc, key, false) end)

    optional
    |> Enum.reduce(default_flag, fn {key, _}, acc -> Map.put(acc, key, nil) end)
  end

  def parse(options, text), do: parse(options, text, fill_defaults(options))

  def parse(%Options{named_key: []}, "", r), do: {:ok, r}
  def parse(%Options{named_key: []}, nil, r), do: {:ok, r}

  def parse(%Options{named_key: [named_key], allow_empty_last: allow_empty}, input, r)
      when input == "" or input == nil do
    if allow_empty do
      {:ok, Map.put(r, named_key, input)}
    else
      {:error, "expected argument '#{named_key}'"}
    end
  end

  def parse(options, input, result) do
    # have named key and input not empty
    input = String.trim(input)

    {:ok, token, rest} = next_token(input)

    cond do
      String.starts_with?(input, "--") ->
        head = String.slice(token, 2..-1)

        case next_token(rest) do
          {:error, _} ->
            {:error, "expected value for option '#{head}'"}

          {:ok, value, rest} ->
            result = put_result(result, head, value)
            parse(options, rest, result)
        end

      String.starts_with?(input, "-") ->
        head = String.slice(token, 1..-1)

        result =
          head
          |> String.graphemes()
          |> Enum.reduce(result, fn key, acc -> Map.put(acc, key, true) end)

        parse(options, rest, result)

      # handle no named key
      options.named_key == [] ->
        {:ok, Map.put(result, "rest", input)}

      length(options.named_key) == 1 ->
        {:ok, Map.put(result, options.named_key |> hd, input)}

      # handle if have named key
      true ->
        value = token
        [key | named_key] = options.named_key
        result = put_result(result, key, value)
        options = %{options | named_key: named_key}
        parse(options, rest, result)
    end
  end

  def add_named(%Options{named: named, named_key: named_key} = opt, name, desc) do
    named = named |> Map.put(name, desc)

    named_key =
      named_key
      |> Enum.filter(fn x -> x != name end)
      |> (fn l -> l ++ [name] end).()

    opt
    |> Map.put(:named, named)
    |> Map.put(:named_key, named_key)
  end

  def add_flag(%Options{flag: flag} = opt, name, desc) do
    flag = Map.put(flag, name, desc)
    opt |> Map.put(:flag, flag)
  end

  def add_optional(%Options{optional: optional} = opt, name, desc) do
    optional = Map.put(optional, name, desc)
    opt |> Map.put(:optional, optional)
  end

  defp put_result(map, key, value) do
    key = to_number(key)
    value = to_number(value)
    Map.put(map, key, value)
  end

  defp to_number(input) do
    case Integer.parse(input) do
      {num, ""} ->
        num

      _ ->
        case Float.parse(input) do
          {num, ""} -> num
          _ -> input
        end
    end
  end
end
