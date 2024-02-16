defmodule Uaddresses.Web.Endpoint do
  @moduledoc """
  Phoenix Endpoint for uaddresses application.
  """
  use Phoenix.Endpoint, otp_app: :uaddresses_api

  # Allow acceptance tests to run in concurrent mode
  if Application.get_env(:uaddresses_api, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  plug(Plug.RequestId)
  plug(EView.Plugs.Idempotency)
  plug(EhealthLogger.Plug, level: Logger.level())

  plug(EView)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(Uaddresses.Web.Router)
end
