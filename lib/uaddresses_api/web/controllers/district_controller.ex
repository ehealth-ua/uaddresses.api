defmodule Uaddresses.Web.DistrictController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Districts
  alias Uaddresses.Districts.District

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

  def settlements(conn, %{"id" => id}) do
    with %District{} = district = Districts.get_district!(id),
      %District{} = district = Districts.preload_settlements(district) do
      render(conn, "list_settlements.json", district: district)
    end
  end

  def search(conn, params) do
    district_name = Map.get(params, "district", "")

    with changeset = %Ecto.Changeset{valid?: true} <- Districts.search_changeset(params) do
      districts =
        :districts
        |> :ets.match_object(get_match_pattern(changeset.changes))
        |> Enum.filter(fn {_, _, _, name} -> String.contains?(name, String.downcase(district_name)) end)
        |> List.foldl([], fn ({district_id, _, _, _}, acc) -> acc ++ [district_id] end)
        |> Districts.list_by_ids()

        render(conn, "search.json", districts: districts)
    end
  end

  defp get_match_pattern(%{region: _region_name, region_id: region_id}) do
    {:"$1", region_id, :"$3", :"$4"}
  end
  defp get_match_pattern(%{region: region_name}) do
    {:"$1", :"$2", String.downcase(region_name), :"$4"}
  end
end