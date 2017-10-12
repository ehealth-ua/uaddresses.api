defmodule Uaddresses.Web.DistrictController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Districts
  alias Uaddresses.Districts.District
  alias Uaddresses.Settlements
  alias Scrivener.Page

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, params) do
    with %Page{} = paging <- Districts.list_districts(params) do
      render(conn, "index.json", districts: paging.entries, paging: paging)
    end
  end

  def create(conn, %{"district" => district_params}) do
    with {:ok, %District{} = district} <- Districts.create_district(district_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", district_path(conn, :show, district))
      |> render("show.json", district: district)
    end
  end

  def show(conn, %{"id" => id}) do
    district = Districts.get_district!(id)
    render(conn, "show.json", district: district)
  end

  def update(conn, %{"id" => id, "district" => district_params}) do
    district = Districts.get_district!(id)

    with {:ok, %District{} = district} <- Districts.update_district(district, district_params) do
      render(conn, "show.json", district: district)
    end
  end

  def delete(conn, %{"id" => id}) do
    district = Districts.get_district!(id)
    with {:ok, %District{}} <- Districts.delete_district(district) do
      send_resp(conn, :no_content, "")
    end
  end

  def settlements(conn, %{"id" => id} = params) do
    search_params =
      params
      |> Map.delete("id")
      |> Map.put("district_id", id)

    with %District{} = district <- Districts.get_district!(id),
         %Page{} = paging <- Settlements.list_settlements(search_params)
    do
      render(conn, "list_settlements.json", district: district, paging: paging, settlements: paging.entries)
    end
  end
end
