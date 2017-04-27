defmodule Uaddresses.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import Uaddresses.Web.Router.Helpers
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      alias Uaddresses.Repo

      # The default endpoint for testing
      @endpoint Uaddresses.Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Uaddresses.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Uaddresses.Repo, {:shared, self()})
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end
end
