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
      {Hibiki.Repo, []},
      {Hibiki.Entity.Data, name: Hibiki.Entity.Data},
      {Hibiki.Cache, name: Hibiki.Cache},
      {Plug.Cowboy,
       scheme: :http,
       plug: Hibiki.Router,
       options: [ip: Application.get_env(:hibiki, :ip), port: Application.get_env(:hibiki, :port)]}
    ]

    Logger.info("Starting application...")

    opts = [strategy: :one_for_one, name: Hibiki.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
