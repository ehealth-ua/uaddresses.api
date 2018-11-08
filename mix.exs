defmodule Uaddresses.Mixfile do
  use Mix.Project

  def project do
    [
      app: :uaddresses_api,
      description: "Add description to your package.",
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      docs: [source_ref: "v#\{@version\}", main: "readme", extras: ["README.md"]]
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
      {:distillery, "~> 2.0"},
      {:grpc, "~> 0.3.0-alpha.2"},
      {:confex, ">= 0.0.0"},
      {:poison, "~> 3.1"},
      {:ecto, "~> 2.1"},
      {:postgrex, "~> 0.13.2"},
      {:phoenix, "~> 1.4.0-rc.3"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, ">= 0.0.0"},
      {:eview, "~> 0.12.2"},
      {:phoenix_ecto, "~> 3.2"},
      {:ex_csv, "~> 0.1.5"},
      {:scrivener_ecto, "~> 1.2"},
      {:plug_logger_json, "~> 0.5"},
      {:ecto_logger_json, "~> 0.1"},
      {:ex_machina, "~> 2.2", only: [:dev, :test]},
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:credo, "~> 0.10.2", only: [:dev, :test]}
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
