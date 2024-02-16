defmodule Uaddresses.Web.V2.RegionController do
  use Uaddresses.Web, :controller

  alias Scrivener.Page
  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements

  action_fallback(Uaddresses.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Regions.list_regions(params) do
      render(conn, "index.json", regions: paging.entries, paging: paging)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.json", region: Regions.get_region!(id))
  end

  def settlements(conn, %{"id" => id} = params) do
    search_params =
      params
      |> Map.delete("id")
      |> Map.put("region_id", id)

    with %Region{} = region <- Regions.get_region!(id),
         %Page{} = paging <- Settlements.list_settlements(search_params) do
      render(conn, "list_settlements.json", region: region, paging: paging, settlements: paging.entries)
    end
  end
end
