defmodule Uaddresses.MixProject do
  use Mix.Project

  @version "1.53.0"
  def project do
    [
      version: @version,
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        filter_prefix: "Uaddresses.Rpc"
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
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]},
      {:credo, "~> 0.10.2", only: [:dev, :test]},
      {:distillery, "~> 2.0"},
      {:git_ops, "~> 0.6.0", only: [:dev]}
    ]
  end
end
