use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

environment :default do
  set(pre_start_hooks: "bin/hooks/")
  set(dev_mode: false)
  set(include_erts: true)
  set(include_src: false)

  set(
    overlays: [
      {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
    ]
  )
end

release :uaddresses_api do
  set(version: current_version(:uaddresses_api))

  set(
    applications: [
      uaddresses_api: :permanent
    ]
  )

  set(config_providers: [ConfexConfigProvider])
end
