defmodule Uaddresses.Web.V1.SettlementController do
  use Uaddresses.Web, :controller

  import Uaddresses.Web.V1Helper

  alias Scrivener.Page
  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement

  action_fallback(Uaddresses.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Settlements.list_settlements(params_to_v1(params)) do
      render(conn, "index.json", settlements: paging.entries, paging: paging)
    end
  end

  def create(conn, params) do
    with {:ok, settlement_params} <- Map.fetch(params, "settlement"),
         {:ok, %Settlement{} = settlement} <- Settlements.create_settlement(params_to_v1(settlement_params)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", settlement_path(conn, :show, settlement))
      |> render("show.json", settlement: settlement)
    else
      :error -> {:error, {:"422", "required property settlement was not present"}}
      error -> error
    end
  end

  def show(conn, %{"id" => id}) do
    settlement = Settlements.get_settlement!(id)
    render(conn, "show.json", settlement: settlement)
  end

  def update(conn, %{"id" => id} = params) do
    settlement = Settlements.get_settlement!(id)

    with {:ok, settlement_params} <- Map.fetch(params, "settlement"),
         update_params <- params_to_v1(settlement_params),
         {:ok, %Settlement{} = settlement} <- Settlements.update_settlement(settlement, update_params) do
      render(conn, "show.json", settlement: settlement)
    else
      :error -> {:error, {:"422", "required property settlement was not present"}}
      error -> error
    end
  end

  def delete(conn, %{"id" => id}) do
    settlement = Settlements.get_settlement!(id)

    with {:ok, %Settlement{}} <- Settlements.delete_settlement(settlement) do
      send_resp(conn, :no_content, "")
    end
  end
end
