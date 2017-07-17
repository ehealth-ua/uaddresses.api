defmodule Uaddresses.Web.RegionController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Regions
  alias Uaddresses.Districts
  alias Uaddresses.Regions.Region

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, _params) do
    regions = Regions.list_regions()
    render(conn, "index.json", regions: regions)
  end

  def create(conn, %{"region" => region_params}) do
    with {:ok, %Region{} = region} <- Regions.create_region(region_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", region_path(conn, :show, region))
      |> render("show.json", region: region)
    end
  end

  def show(conn, %{"id" => id}) do
    region = Regions.get_region!(id)
    render(conn, "show.json", region: region)
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    with %Uaddresses.Regions.Region{} = region = Regions.get_region!(id),
      {:ok, %Region{} = region} <- Regions.update_region(region, region_params) do
      render(conn, "show.json", region: region)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = Regions.get_region!(id)
    with {:ok, %Region{}} <- Regions.delete_region(region) do
      send_resp(conn, :no_content, "")
    end
  end

  def districts(conn, %{"id" => id} = params) do
    with %Uaddresses.Regions.Region{} = Regions.get_region!(id),
      {districts, paging} = Districts.get_by_region_id(id, params),
      districts = filter_districts_by_name(districts, params) do
      render(conn, "list_districts.json", districts: districts, paging: paging)
    end
  end

  def search(conn, params) do
    with {:ok, regions, paging} <- Regions.search(params) do
      render(conn, "index.json", regions: regions, paging: paging)
    end
  end

  def filter_districts_by_name(districts, params) do
    name =
      params
      |> Map.get("name", "")
      |> String.downcase()

    Enum.filter(districts, fn (district) -> String.contains?(String.downcase(district.name), name) end)
  end
end
