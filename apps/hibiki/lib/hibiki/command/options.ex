defmodule Hibiki.Command.Options do
  defstruct named: %{}, named_key: [], flag: %{}, optional: %{}, allow_empty_last: false

  @type t :: %__MODULE__{
          named: map,
          named_key: [binary],
          flag: map,
          optional: map,
          allow_empty_last: bool
        }

  alias Hibiki.Command.Options

  def add_named(%Options{named: named, named_key: named_key} = opt, name, desc \\ "") do
    named = named |> Map.put(name, desc)

    named_key =
      named_key
      |> Enum.filter(fn x -> x != name end)
      |> (fn l -> l ++ [name] end).()

    opt
    |> Map.put(:named, named)
    |> Map.put(:named_key, named_key)
  end

  def add_flag(%Options{flag: flag} = opt, name, desc \\ "") do
    flag = Map.put(flag, name, desc)
    Map.put(opt, :flag, flag)
  end

  def add_optional(%Options{optional: optional} = opt, name, desc \\ "") do
    optional = Map.put(optional, name, desc)
    Map.put(opt, :optional, optional)
  end
end

defmodule Hibiki.Command.Options.Describe do
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

  def generate_usage_description(%Options{
        flag: flag,
        optional: optional,
        named_key: named_key,
        named: named
      }) do
    map_filter_empty_key = fn x ->
      x |> Enum.filter(fn {_, v} -> v != "" end)
    end

    flag = map_filter_empty_key.(flag)

    flag_desc =
      if length(flag) > 0 do
        flag
        |> Enum.filter(fn {_, desc} -> String.trim(desc) != "" end)
        |> Enum.map(fn {opt, desc} -> " -#{opt} : #{desc}" end)
        |> Enum.join("\n")
        |> (fn x -> "Flags:\n" <> x end).()
      else
        ""
      end

    optional = map_filter_empty_key.(optional)

    optional_desc =
      if length(optional) > 0 do
        optional
        |> Enum.filter(fn {_, desc} -> String.trim(desc) != "" end)
        |> Enum.map(fn {opt, desc} -> " --#{opt} <>: #{desc}" end)
        |> Enum.join("\n")
        |> (fn x -> "Optional:\n" <> x end).()
      else
        ""
      end

    named_desc =
      if length(named_key) > 0 do
        named_key
        |> Enum.map(fn key -> " #{key}: #{named[key]}" end)
        |> Enum.join("\n")
        |> (fn x -> "Named:\n" <> x end).()
      else
        ""
      end

    [
      flag_desc,
      optional_desc,
      named_desc
    ]
    |> Enum.filter(fn x -> String.trim(x) != "" end)
    |> Enum.join("\n\n")
    |> String.trim()
  end
end

defmodule Hibiki.Command.Options.Parser do
  import Hibiki.Parser, only: [next_token: 1]
  alias Hibiki.Command.Options

  def parse(options, text), do: parse(options, text, fill_defaults(options))

  def parse(%Options{named_key: []}, "", r), do: {:ok, r}
  def parse(%Options{named_key: []}, nil, r), do: {:ok, r}

  def parse(%Options{named_key: [named_key], allow_empty_last: true}, input, r)
      when input == "" or input == nil do
    {:ok, Map.put(r, named_key, input)}
  end

  def parse(%Options{named_key: [named_key], allow_empty_last: false}, input, _)
      when input == "" or input == nil do
    {:error, "expected argument '#{named_key}'"}
  end

  def parse(options, input, result) do
    # have named key and input not empty
    input = String.trim(input)

    {:ok, token, rest} =
      input
      |> String.trim()
      |> next_token()

    cond do
      String.starts_with?(input, "--") ->
        # Handle optional
        head = String.slice(token, 2..-1)

        case next_token(rest) do
          {:error, _} ->
            {:error, "expected value for option '#{head}'"}

          {:ok, value, rest} ->
            result = put_result(result, head, value)
            parse(options, rest, result)
        end

      String.starts_with?(input, "-") ->
        # Handle flag
        head = String.slice(token, 1..-1)

        result =
          head
          |> String.graphemes()
          |> Enum.reduce(result, fn key, acc -> Map.put(acc, key, true) end)

        parse(options, rest, result)

      options.named_key == [] ->
        # handle no named key
        {:ok, Map.put(result, "rest", input)}

      length(options.named_key) == 1 ->
        {:ok, Map.put(result, options.named_key |> hd, input)}

      true ->
        # handle if have named key
        [key | named_key] = options.named_key
        result = put_result(result, key, token)
        options = %{options | named_key: named_key}
        parse(options, rest, result)
    end
  end

  defp fill_defaults(%Options{flag: flag, optional: optional}) do
    default_flag =
      flag
      |> Enum.reduce(%{}, fn {key, _}, acc -> Map.put(acc, key, false) end)

    optional
    |> Enum.reduce(default_flag, fn {key, _}, acc -> Map.put(acc, key, nil) end)
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
