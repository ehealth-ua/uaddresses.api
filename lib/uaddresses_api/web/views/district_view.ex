defmodule Uaddresses.Web.DistrictView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.DistrictView

  def render("index.json", %{districts: districts}) do
    render_many(districts, DistrictView, "district.json")
  end

  def render("search.json", %{districts: districts}) do
    render_many(districts, DistrictView, "search_one.json")
  end

  def render("show.json", %{district: district}) do
    render_one(district, DistrictView, "district.json")
  end

  def render("district.json", %{district: district}) do
    %{
      id: district.id,
      region_id: district.region_id,
      name: district.name
    }
  end

  def render("search_one.json", %{district: district}) do
    %{
      id: district.id,
      region: district.region.name,
      district: district.name
    }
  end

  def render("district_by_region.json", %{district: district}) do
    %{
      id: district.id,
      district: district.name
    }
  end

  def render("list_settlements.json", %{settlements: settlements}) do
    render_many(settlements, Uaddresses.Web.SettlementView, "settlement_by_district.json")
  end
end
