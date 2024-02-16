defmodule Uaddresses.Web.V2.AreaController do
  use Uaddresses.Web, :controller

  alias Scrivener.Page
  alias Uaddresses.Areas
  alias Uaddresses.Areas.Area
  alias Uaddresses.Regions

  action_fallback(Uaddresses.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Areas.list_areas(params) do
      render(conn, "index.json", areas: paging.entries, paging: paging)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.json", area: Areas.get_area!(id))
  end

  def regions(conn, %{"id" => id} = params) do
    search_params =
      params
      |> Map.delete("id")
      |> Map.put("area_id", id)

    with %Area{} <- Areas.get_area!(id),
         %Page{} = paging <- Regions.list_regions(search_params) do
      render(conn, "list_regions.json", regions: paging.entries, paging: paging)
    end
  end
end
