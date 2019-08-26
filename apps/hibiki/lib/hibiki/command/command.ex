defmodule Hibiki.Command do
  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback subcommands() :: [module()]
  @callback options() :: Hibiki.Command.Options.t()
  @callback private() :: bool
  @callback handle(args :: any, context :: Hibiki.Command.Context.t()) ::
              Hibiki.Command.Context.t() | {:error, any()}
  @callback pre_handle(args :: any, context :: Hibiki.Command.Context.t()) ::
              {:ok, args :: any, ctx :: Hibiki.Command.Context.t()}
              | {:error, any}
              | {:stop, Hibiki.Command.Context.t()}

  defmacro __using__(_opts) do
    quote do
      alias Hibiki.Command.Options, as: Options
      import Hibiki.Command.Context
      @behaviour Hibiki.Command
      def description, do: ""
      def subcommands, do: []
      def options, do: %Hibiki.Command.Options{}
      def private, do: false
      def handle(_, _), do: {:error, "#{__MODULE__} UNIMPLEMENTED!"}
      def pre_handle(args, ctx), do: {:ok, args, ctx}

      defoverridable(Hibiki.Command)
    end
  end
end
