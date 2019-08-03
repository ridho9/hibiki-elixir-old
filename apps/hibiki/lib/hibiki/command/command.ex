defmodule Hibiki.Command do
  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback subcommands() :: [module()]
  @callback options() :: Hibiki.Command.Options.t()
  @callback private() :: bool
  @callback handle(args :: any, context :: any) :: Hibiki.Command.Context.t() | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      alias Hibiki.Command.Options, as: Options
      import Hibiki.Command.Context
      @behaviour Hibiki.Command
      def description, do: ""
      def subcommands, do: []
      def options, do: %Hibiki.Command.Options{}
      def private, do: false
      defoverridable(Hibiki.Command)
    end
  end
end
