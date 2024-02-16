import Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.

config :git_ops,
  mix_project: Uaddresses.MixProject,
  changelog_file: "CHANGELOG.md",
  repository_url: "https://github.com/edenlabllc/uaddresses.api/",
  types: [
    # Makes an allowed commit type called `tidbit` that is not
    # shown in the changelog
    tidbit: [
      hidden?: true
    ],
    # Makes an allowed commit type called `important` that gets
    # a section in the changelog with the header "Important Changes"
    important: [
      header: "Important Changes"
    ]
  ],
  # Instructs the tool to manage your mix version in your `mix.exs` file
  # See below for more information
  manage_mix_version?: true,
  # Instructs the tool to manage the version in your README.md
  # Pass in `true` to use `"README.md"` or a string to customize
  manage_readme_version: "README.md"

for config <- Path.join([__DIR__, "../apps/*/config/config.exs"]) |> Path.expand() |> Path.wildcard() do
  import_config config
end
