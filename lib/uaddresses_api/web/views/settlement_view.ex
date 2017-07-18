defmodule Uaddresses.Web.SettlementView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.SettlementView

  def render("index.json", %{settlements: settlements}) do
    render_many(settlements, SettlementView, "settlement.json")
  end

  def render("show.json", %{settlement: settlement}) do
    render_one(settlement, SettlementView, "settlement.json")
  end

  def render("settlement.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      type: settlement.type,
      district: get_name(settlement.district),
      district_id: settlement.district_id,
      region: settlement.region.name,
      region_id: settlement.region_id,
      parent_settlement: get_name(settlement.parent_settlement),
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

  defp get_name(nil), do: nil
  defp get_name(obj), do: obj.name
end
