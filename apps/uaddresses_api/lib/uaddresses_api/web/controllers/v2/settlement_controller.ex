defmodule Uaddresses.Web.V2.SettlementController do
  use Uaddresses.Web, :controller

  alias Scrivener.Page
  alias Uaddresses.Settlements

  action_fallback(Uaddresses.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Settlements.list_settlements(params) do
      render(conn, "index.json", settlements: paging.entries, paging: paging)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.json", settlement: Settlements.get_settlement!(id))
  end
end
