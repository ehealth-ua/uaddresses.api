defmodule Uaddresses.Web.RegionController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Regions
  alias Uaddresses.Districts
  alias Uaddresses.Regions.Region
  alias Scrivener.Page

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, params) do
    with %Page{} = paging <- Regions.list_regions(params) do
      render(conn, "index.json", regions: paging.entries, paging: paging)
    end
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
    search_params =
      params
      |> Map.delete("id")
      |> Map.put("region_id", id)

    with %Uaddresses.Regions.Region{} <- Regions.get_region!(id),
         %Page{} = paging <- Districts.list_districts(search_params)
    do
      render(conn, "list_districts.json", districts: paging.entries, paging: paging)
    end
  end
end
