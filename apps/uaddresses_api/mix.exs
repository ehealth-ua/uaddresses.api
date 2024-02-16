defmodule Uaddresses.Mixfile do
  use Mix.Project

  def project do
    [
      version: "0.1.0",
      app: :uaddresses_api,
      description: "Add description to your package.",
      version: "0.1.0",
      elixir: "~> 1.12.2",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger, :runtime_tools], mod: {Uaddresses, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:kube_rpc, "~> 0.4.2"},
      {:jason, "~> 1.2"},
      {:ecto, "~> 3.7.0"},
      {:ecto_sql, "~> 3.7.0"},
      {:ecto_filter, "~> 0.3.0"},
      {:postgrex, "~> 0.15.10"},
      {:phoenix, "~> 1.6.0"},
      {:plug_cowboy, "~> 2.5.1"},
      {:httpoison, "~> 1.8.0"},
      {:eview, "~> 0.16.0"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:scrivener_ecto, "~> 2.7.0"},
      {:nex_json_schema, "~> 0.8.4"},
      {:ehealth_logger, git: "https://github.com/edenlabllc/ehealth_logger.git"},
      {:ex_machina, "~> 2.7.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.26.0", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
