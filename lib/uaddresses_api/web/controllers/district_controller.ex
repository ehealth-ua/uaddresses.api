defmodule Uaddresses.Web.DistrictController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Districts
  alias Uaddresses.Districts.District

  alias Uaddresses.Settlements

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, _params) do
    districts = Districts.list_districts()
    render(conn, "index.json", districts: districts)
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
    with %District{} = district = Districts.get_district!(id),
      {settlements, paging} = Settlements.get_settlements_by_district_id(id, params),
      settlements = filter_settlements(settlements, params) do
      render(conn, "list_settlements.json", district: district, paging: paging, settlements: settlements)
    end
  end

  def search(conn, params) do
    with {:ok, districts, paging} <- Districts.search(params) do
      render(conn, "index.json", districts: districts, paging: paging)
    end
  end

  defp filter_settlements(settlements, params) do
    settlement_name = Map.get(params, "name", "")
    Enum.filter(settlements,
      fn (settlement) -> String.contains?(String.downcase(settlement.name), String.downcase(settlement_name)) end)
  end
end
