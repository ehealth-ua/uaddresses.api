defmodule Uaddresses.Web.V2.AreaView do
  use Uaddresses.Web, :view

  alias Uaddresses.Web.V2.RegionView

  @fields ~w(id name koatuu)a

  def render("index.json", %{areas: areas}) do
    render_many(areas, __MODULE__, "show.json")
  end

  def render("show.json", %{area: area}), do: Map.take(area, @fields)

  def render("list_regions.json", %{regions: regions}) do
    render_many(regions, RegionView, "region_by_area.json")
  end
end
