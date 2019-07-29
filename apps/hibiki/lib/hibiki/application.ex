defmodule Hibiki.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Hibiki.Worker.start_link(arg)
      # {Hibiki.Worker, arg}
      {Plug.Cowboy,
       scheme: :http, plug: Hibiki.Router, options: [port: Application.get_env(:hibiki, :port)]},
      {Hibiki.Repo, []}
    ]

    Logger.info("Starting application...")

    opts = [strategy: :one_for_one, name: Hibiki.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
