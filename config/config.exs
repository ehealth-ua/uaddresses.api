# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :uaddresses_api,
  namespace: Uaddresses,
  ecto_repos: [Uaddresses.Repo],
  grpc_port: {:system, :integer, "GRPC_PORT", 50_051}

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

config :grpc, start_server: true

import_config "#{Mix.env()}.exs"
