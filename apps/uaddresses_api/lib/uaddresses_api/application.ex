defmodule Uaddresses do
  @moduledoc """
  This is an entry point of uaddresses application.
  """

  use Application

  alias EhealthLogger.Phoenix.TelemetryHandler
  alias Uaddresses.Repo
  alias Uaddresses.Web.Endpoint

  def start(_type, _args) do
    children = [
      {Repo, []},
      {Endpoint, []}
    ]

    :telemetry.attach("log-handler", [:uaddresses, :repo, :query], &Uaddresses.TelemetryHandler.handle_event/4, nil)
    :telemetry.attach("phoenix-error-handler", [:phoenix, :error_rendered], &TelemetryHandler.handle_event/4, nil)

    opts = [strategy: :rest_for_one, name: Uaddresses.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
