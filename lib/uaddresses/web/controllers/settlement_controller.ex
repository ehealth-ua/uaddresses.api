defmodule Uaddresses.Web.SettlementController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, _params) do
    settlements = Settlements.list_settlements()
    render(conn, "index.json", settlements: settlements)
  end

  def create(conn, %{"settlement" => settlement_params}) do
    with {:ok, %Settlement{} = settlement} <- Settlements.create_settlement(settlement_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", settlement_path(conn, :show, settlement))
      |> render("show.json", settlement: settlement)
    end
  end

  def show(conn, %{"id" => id}) do
    settlement = Settlements.get_settlement!(id)
    render(conn, "show.json", settlement: settlement)
  end

  def update(conn, %{"id" => id, "settlement" => settlement_params}) do
    settlement = Settlements.get_settlement!(id)

    with {:ok, %Settlement{} = settlement} <- Settlements.update_settlement(settlement, settlement_params) do
      render(conn, "show.json", settlement: settlement)
    end
  end

  def delete(conn, %{"id" => id}) do
    settlement = Settlements.get_settlement!(id)
    with {:ok, %Settlement{}} <- Settlements.delete_settlement(settlement) do
      send_resp(conn, :no_content, "")
    end
  end
end
