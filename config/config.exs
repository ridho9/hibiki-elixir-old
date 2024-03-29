# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
config :hibiki,
  ip: {127, 0, 0, 1},
  port: 8080,
  channel_access_token: "",
  channel_secret: "",
  admin_id: [],
  ecto_repos: [Hibiki.Repo]

config :hibiki, Hibiki.Repo,
  database: "hibiki",
  username: "user",
  password: "pass",
  hostname: "localhost",
  imgflip_username: "username",
  imgflip_password: "password"

config :logger, :console,
  metadata: [:token],
  compile_time_purge_matching: [
    [level_lower_than: :warn]
  ]

#
# and access this configuration in your application as:
#
#     Application.get_env(:hibiki, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
