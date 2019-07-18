defmodule LineSDK.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_sdk,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: truee
      {:recase, "~> 0.5"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:mock, "~> 0.3.0", only: :test},
      {:plug, "~> 1.8"},
      {:dialyxir, "~> 0.4", only: [:dev]}
    ]
  end
end
