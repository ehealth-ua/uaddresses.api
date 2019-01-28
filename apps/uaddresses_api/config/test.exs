use Mix.Config

# Configuration for test environment
config :ex_unit, capture_log: true

# Configure your database
config :uaddresses_api, Uaddresses.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "uaddresses_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 120_000_000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :uaddresses_api, Uaddresses.Web.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Run acceptance test in concurrent mode
config :uaddresses_api, sql_sandbox: true