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
      region: settlement.region.name,
      district: settlement.district.name,
      settlement_name: settlement.name
    }
  end

  def render("settlement.json", %{settlement: settlement}) do
    %{id: settlement.id,
      district_id: settlement.district_id,
      region_id: settlement.region_id,
      name: settlement.name}
  end

  def render("settlement_by_district.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      settlement_name: settlement.name
    }
  end
end
