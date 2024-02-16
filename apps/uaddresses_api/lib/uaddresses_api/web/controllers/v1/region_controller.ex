defmodule Uaddresses.Web.V1.RegionController do
  use Uaddresses.Web, :controller

  import Uaddresses.Web.V1Helper

  alias Scrivener.Page
  alias Uaddresses.Areas
  alias Uaddresses.Areas.Area
  alias Uaddresses.Regions

  action_fallback(Uaddresses.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- Areas.list_areas(params) do
      render(conn, "index.json", regions: paging.entries, paging: paging)
    end
  end

  def create(conn, %{"region" => region_params}) do
    with {:ok, %Area{} = area} <- Areas.create_area(region_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", region_path(conn, :show, area))
      |> render("show.json", region: area)
    end
  end

  def show(conn, %{"id" => id}) do
    region = Areas.get_area!(id)
    render(conn, "show.json", region: region)
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    with %Uaddresses.Areas.Area{} = region <- Areas.get_area!(id),
         {:ok, %Area{} = region} <- Areas.update_area(region, region_params) do
      render(conn, "show.json", region: region)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = Areas.get_area!(id)

    with {:ok, %Area{}} <- Areas.delete_area(region) do
      send_resp(conn, :no_content, "")
    end
  end

  def districts(conn, %{"id" => id} = params) do
    search_params =
      params
      |> params_to_v1()
      |> Map.delete("id")
      |> Map.put("area_id", id)

    with %Uaddresses.Areas.Area{} <- Areas.get_area!(id),
         %Page{} = paging <- Regions.list_regions(search_params) do
      render(conn, "list_districts.json", districts: paging.entries, paging: paging)
    end
  end
end
