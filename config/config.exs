# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :uaddresses_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:uaddresses_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"
config :uaddresses_api,
  namespace: Uaddresses,
  ecto_repos: [Uaddresses.Repo]

# Configure your database
config :uaddresses_api, Uaddresses.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME", "uaddresses_dev"},
  username: {:system, "DB_USER", "postgres"},
  password: {:system, "DB_PASSWORD", "postgres"},
  hostname: {:system, "DB_HOST", "localhost"},
  port: {:system, :integer, "DB_PORT", 5432},
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
# Configures the endpoint
config :uaddresses_api, Uaddresses.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kCj2tpqzsnxcsciNm5JLDnUgJChdtFCO5RMyIlnUfSw1bhxxgYGvM/OX3v2mosnU",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
