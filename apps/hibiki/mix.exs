defmodule Hibiki.MixProject do
  use Mix.Project

  def project do
    [
      app: :hibiki,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Hibiki.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:mimerl, "~> 1.2"},
      {:temp, "~> 0.4.7"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:line_sdk, in_umbrella: true},
      {:dice_roll, in_umbrella: true},
      {:mock, "~> 0.3.0", only: [:test]},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:plug_cowboy, "~> 2.1"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
