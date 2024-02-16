defmodule Uaddresses.MixProject do
  use Mix.Project

  @version "2.3.0"
  def project do
    [
      name: "uaddresses.api",
      version: @version,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        filter_modules: "^.*\.Rpc$"
      ],
      releases: [
        uaddresses_api: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent, uaddresses_api: :permanent]
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:excoveralls, "~> 0.14.2", only: [:dev, :test]},
      {:plug, "~> 1.12.1"},
      {:credo, "~> 1.6.1", only: [:dev, :test]},
      {:git_ops, "~> 2.4.5", only: [:dev]}
    ]
  end
end
