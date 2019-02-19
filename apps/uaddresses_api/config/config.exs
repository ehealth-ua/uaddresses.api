# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :uaddresses_api,
  namespace: Uaddresses,
  ecto_repos: [Uaddresses.Repo]

# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
# Configures the endpoint
config :uaddresses_api, Uaddresses.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kCj2tpqzsnxcsciNm5JLDnUgJChdtFCO5RMyIlnUfSw1bhxxgYGvM/OX3v2mosnU",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

config :logger_json, :backend,
  formatter: EhealthLogger.Formatter,
  metadata: :all

config :logger,
  backends: [LoggerJSON],
  level: :debug

import_config "#{Mix.env()}.exs"
