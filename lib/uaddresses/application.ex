defmodule Uaddresses do
  @moduledoc """
  This is an entry point of uaddresses application.
  """

  use Application
  alias Uaddresses.Web.Endpoint

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

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uaddresses.Supervisor]

    setup_ets_tables()

    Supervisor.start_link(children, opts)

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  # Loads configuration in `:on_init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def load_from_system_env(config) do
    {:ok, Confex.process_env(config)}
  end

  def setup_ets_tables do
    # {region_id, region_name}
    :ets.new(:regions, [:set, :public, :named_table])
    # {district_id, region_id, region_name, district_name}
    :ets.new(:districts, [:set, :public, :named_table])
    # {settlement_id, region_id, district_id, region_name, district_name, settlement.name}
    :ets.new(:settlements, [:set, :public, :named_table])
    # {street_ id, settlement_id,region_name, district_name, settlement_name, street_name, street_type,
    # street_number, street_postal_code,
    :ets.new(:streets, [:set, :public, :named_table, :duplicate_bag])
  end
end
