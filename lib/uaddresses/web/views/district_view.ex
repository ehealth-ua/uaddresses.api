defmodule Uaddresses.Web.DistrictView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.DistrictView

  def render("index.json", %{districts: districts}) do
    render_many(districts, DistrictView, "district.json")
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
end
