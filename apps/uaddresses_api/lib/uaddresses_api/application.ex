defmodule Uaddresses do
  @moduledoc """
  This is an entry point of uaddresses application.
  """

  use Application
  alias Uaddresses.Repo
  alias Uaddresses.Web.Endpoint

  def start(_type, _args) do
    children = [
      {Repo, []},
      {Endpoint, []}
    ]

    opts = [strategy: :rest_for_one, name: Uaddresses.Supervisor]
    :telemetry.attach("log-handler", [:uaddresses, :repo, :query], &Uaddresses.TelemetryHandler.handle_event/4, nil)

    Supervisor.start_link(children, opts)
  end
end
