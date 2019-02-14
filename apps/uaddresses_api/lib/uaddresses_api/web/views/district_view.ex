defmodule Uaddresses.Web.DistrictView do
  use Uaddresses.Web, :view

  @fields ~w(id region_id name koatuu)a

  def render("index.json", %{districts: districts}) do
    render_many(districts, __MODULE__, "district.json")
  end

  def render("index.rpc.json", %{districts: districts}) do
    render_many(districts, __MODULE__, "district.rpc.json")
  end

  def render("show.json", %{district: district}) do
    render_one(district, __MODULE__, "district.json")
  end

  def render("district.json", %{district: district}) do
    district
    |> Map.take(@fields)
    |> Map.put(:region, district.region.name)
  end

  def render("district.rpc.json", %{district: district}) do
    Map.take(district, @fields)
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
