defmodule Uaddresses.Web.RegionView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.RegionView

  def render("index.json", %{regions: regions}) do
    render_many(regions, RegionView, "region.json")
  end

  def render("show.json", %{region: region}) do
    render_one(region, RegionView, "region.json")
  end

  def render("region.json", %{region: region}) do
    %{
      id: region.id,
      name: region.name,
      koatuu: region.koatuu
    }
  end

  def render("list_districts.json", %{districts: districts}) do
    render_many(districts, Uaddresses.Web.DistrictView, "district_by_region.json")
  end
end
