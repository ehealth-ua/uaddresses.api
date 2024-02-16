defmodule Uaddresses.Web.V2.RegionView do
  use Uaddresses.Web, :view

  alias Uaddresses.Web.V2.SettlementView

  @fields ~w(id name koatuu area_id)a

  def render("index.json", %{regions: regions}) do
    render_many(regions, __MODULE__, "show.json")
  end

  def render("show.json", %{region: region}) do
    region
    |> Map.take(@fields)
    |> Map.put(:area, region.area.name)
  end

  def render("region_by_area.json", %{region: region}) do
    %{
      id: region.id,
      region: region.name
    }
  end

  def render("list_settlements.json", %{settlements: settlements}) do
    render_many(settlements, SettlementView, "settlement_by_region.json")
  end
end
