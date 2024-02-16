import Config

config :uaddresses_api, Uaddresses.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT", "5432"),
  pool_size: String.to_integer(System.get_env("DB_POOL_SIZE", "10")),
  timeout: 15_000

config :uaddresses_api, Uaddresses.Web.Endpoint,
  load_from_system_env: true,
  http: [port: System.get_env("PORT")],
  url: [
    host: System.get_env("HOST", "localhost"),
    port: System.get_env("PORT")
  ],
  secret_key_base: System.get_env("SECRET_KEY"),
  debug_errors: false,
  code_reloader: false
