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

  def search(conn, params) do
    settlement_name = Map.get(params, "settlement_name", "")

    with changeset = %Ecto.Changeset{valid?: true} <- Settlements.search_changeset(params) do
      settlements =
        :settlements
        |> :ets.match_object(get_match_pattern(changeset.changes))
        |> Enum.filter(fn {_, _, _, _, _, name} -> String.contains?(name, String.downcase(settlement_name)) end)
        |> List.foldl([], fn ({settlement_id, _, _, _, _, _}, acc) -> acc ++ [settlement_id] end)
        |> Settlements.list_by_ids()

        render(conn, "search.json", settlements: settlements)
    end
  end
#  {
#          settlement.id,
#          settlement.region_id,
#          settlement.district_id,
#          String.downcase(region_name),
#          String.downcase(district_name),
#          String.downcase(settlement.name)
#        }

  defp get_match_pattern(%{region: region_name, district: district_name}) do
    {:"$1", :"$2", :"$3", String.downcase(region_name), String.downcase(district_name), :"$6"}
  end
  defp get_match_pattern(%{region: region_name}) do
    {:"$1", :"$2", :"$3", String.downcase(region_name), :"$4", :"$6"}
  end
end
