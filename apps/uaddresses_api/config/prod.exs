import Config

# Do not log passwords, card data and tokens
config :phoenix, :filter_parameters, ["password", "secret", "token", "password_confirmation", "card", "pan", "cvv"]

config :phoenix, :serve_endpoints, true
