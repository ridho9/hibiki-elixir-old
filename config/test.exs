# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

config :hibiki,
  channel_access_token: "cat",
  channel_secret: "cs"

config :hibiki, Hibiki.Repo,
  username: "postgres",
  password: "postgres",
  database: "hibiki_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
