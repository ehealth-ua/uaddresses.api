use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

cookie = :sha256
|> :crypto.hash(System.get_env("ERLANG_COOKIE") || "1s8BoxlWXKavERdCcFHO3asGX3lG/YDncoSaOt+w2W7Mo4GdKa1/otpXOnkmFZ/0")
|> Base.encode64

environment :default do
  set pre_start_hook: "bin/hooks/pre-start.sh"
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set cookie: cookie
end

release :uaddresses_api do
  set version: current_version(:uaddresses_api)
  set applications: [
    uaddresses_api: :permanent
  ]
end
