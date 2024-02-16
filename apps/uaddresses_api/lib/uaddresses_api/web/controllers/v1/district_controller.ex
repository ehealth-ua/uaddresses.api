defmodule Uaddresses.Web.V1.DistrictController do
  use Uaddresses.Web, :controller

  import Uaddresses.Web.V1Helper

  alias Scrivener.Page
  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements

  action_fallback(Uaddresses.Web.FallbackController)

  def index(conn, params) do
    search_params = params_to_v1(params)

    with %Page{} = paging <- Regions.list_regions(search_params) do
      render(conn, "index.json", districts: paging.entries, paging: paging)
    end
  end

  def create(conn, %{"district" => district_params}) do
    create_data = params_to_v1(district_params)

    with {:ok, %Region{} = district} <- Regions.create_region(create_data) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", district_path(conn, :show, district))
      |> render("show.json", district: district)
    end
  end

  def show(conn, %{"id" => id}) do
    district = Regions.get_region!(id)
    render(conn, "show.json", district: district)
  end

  def update(conn, %{"id" => id, "district" => district_params}) do
    district = Regions.get_region!(id)
    update_data = params_to_v1(district_params)

    with {:ok, %Region{} = region} <- Regions.update_region(district, update_data) do
      render(conn, "show.json", district: region)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = Regions.get_region!(id)

    with {:ok, %Region{}} <- Regions.delete_region(region) do
      send_resp(conn, :no_content, "")
    end
  end

  def settlements(conn, %{"id" => id} = params) do
    search_params =
      params
      |> params_to_v1()
      |> Map.delete("id")
      |> Map.put("region_id", id)

    with %Region{} = district <- Regions.get_region!(id),
         %Page{} = paging <- Settlements.list_settlements(search_params) do
      render(conn, "list_settlements.json", district: district, paging: paging, settlements: paging.entries)
    end
  end
end
