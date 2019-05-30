defmodule Uaddresses.Web.V1.RegionView do
  use Uaddresses.Web, :view

  alias Uaddresses.Web.V1.DistrictView

  @fields ~w(id name koatuu)a

  def render("index.json", %{regions: regions}) do
    render_many(regions, __MODULE__, "region.json")
  end

  def render("index.rpc.json", %{regions: regions}) do
    render_many(regions, __MODULE__, "region.rpc.json")
  end

  def render("show.json", %{region: region}) do
    render_one(region, __MODULE__, "region.json")
  end

  def render("region.json", %{region: region}), do: Map.take(region, @fields)

  def render("region.rpc.json", %{region: region}), do: Map.take(region, @fields ++ [:inserted_at, :updated_at])

  def render("list_districts.json", %{districts: districts}) do
    render_many(districts, DistrictView, "district_by_region.json")
  end
end
