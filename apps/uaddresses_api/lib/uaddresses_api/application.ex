defmodule Uaddresses do
  @moduledoc """
  This is an entry point of uaddresses application.
  """

  use Application
  alias Confex.Resolver
  alias Uaddresses.Web.Endpoint

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Uaddresses.Repo, []),
      supervisor(Uaddresses.Web.Endpoint, [])
    ]

    opts = [strategy: :rest_for_one, name: Uaddresses.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  @doc false
  def init(_key, config) do
    Resolver.resolve(config)
  end
end
