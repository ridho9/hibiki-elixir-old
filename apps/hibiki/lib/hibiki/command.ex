defmodule Hibiki.Command do
  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback subcommands() :: [module()]
  @callback options() :: any
  @callback handle(args :: any, context :: any) :: Hibiki.Context.t() | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      alias Hibiki.Command.Options
      import Hibiki.Context
      @behaviour Hibiki.Command
      def description, do: ""
      def subcommands, do: []
      def options, do: %Hibiki.Command.Options{}
      def private, do: false
      defoverridable(Hibiki.Command)
    end
  end

  defmodule Options do
    defstruct named: %{}, named_key: [], flag: %{}, optional: %{}

    import Hibiki.Util, only: [next_token: 1]

    def parse(options, text), do: parse(options, text, %{})

    def parse(%Options{named_key: []}, input, r)
        when input == "" or input == nil do
      {:ok, r}
    end

    def parse(%Options{named_key: [key]}, input, r) do
      if not String.starts_with?(input, "-") do
        {:ok, Map.put(r, key, input)}
      else
      end
    end

    def parse(%Options{named_key: named_key}, input, _)
        when input == "" or input == nil do
      {:error, "expected argument '#{hd(named_key)}'"}
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

        # handle flag
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
  end
end
