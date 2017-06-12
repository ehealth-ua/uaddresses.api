defmodule Uaddresses.Web.SettlementView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.SettlementView

  def render("index.json", %{settlements: settlements}) do
    render_many(settlements, SettlementView, "settlement.json")
  end

  def render("show.json", %{settlement: settlement}) do
    render_one(settlement, SettlementView, "settlement.json")
  end

  def render("search.json", %{settlements: settlements}) do
    render_many(settlements, SettlementView, "search_one.json")
  end

  def render("search_one.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      type: settlement.type,
      region: settlement.region.name,
      district: get_name(settlement.district),
      parent_settlement: get_name(settlement.parent_settlement),
      settlement_name: settlement.name,
      mountain_group: settlement.mountain_group,
      koatuu: settlement.koatuu
    }
  end

  defp get_name(nil), do: nil
  defp get_name(obj), do: obj.name

  def render("settlement.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      type: settlement.type,
      district_id: settlement.district_id,
      region_id: settlement.region_id,
      parent_settlement_id: settlement.parent_settlement_id,
      name: settlement.name,
      mountain_group: settlement.mountain_group,
      koatuu: settlement.koatuu
    }
  end

  def render("settlement_by_district.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      settlement_name: settlement.name
    }
  end
end
