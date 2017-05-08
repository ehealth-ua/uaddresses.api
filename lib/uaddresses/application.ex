defmodule Uaddresses do
  @moduledoc """
  This is an entry point of uaddresses application.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Uaddresses.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Uaddresses.Web.Endpoint, []),
      # Starts a worker by calling: Uaddresses.Worker.start_link(arg1, arg2, arg3)
      # worker(Uaddresses.Worker, [arg1, arg2, arg3]),
    ]

    setup_ets_tables()

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uaddresses.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Uaddresses.Web.Endpoint.config_change(changed, removed)
    :ok
  end

  # Loads configuration in `:on_init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def load_from_system_env(config) do
    {:ok, Confex.process_env(config)}
  end

  def setup_ets_tables() do
    :ets.new(:regions, [:set, :public, :named_table])
    :ets.new(:districts, [:set, :public, :named_table])
    :ets.new(:settlements, [:set, :public, :named_table])
  end
end
