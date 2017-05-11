defmodule Uaddresses.Web.StreetController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Streets
  alias Uaddresses.Streets.Street

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, _params) do
    streets = Streets.list_streets()
    render(conn, "index.json", streets: streets)
  end

  def create(conn, %{"street" => street_params}) do
    with {:ok, %Street{} = street} <- Streets.create_street(street_params),
     %Street{} = street = Streets.preload_aliases(street) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", street_path(conn, :show, street))
      |> render("show.json", street: street)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Street{} = street = Streets.get_street!(id),
     %Street{} = street = Streets.preload_aliases(street) do
      render(conn, "show.json", street: street)
    end
  end

  def update(conn, %{"id" => id, "street" => street_params}) do
    street = Streets.get_street!(id)

    with {:ok, %Street{} = street} <- Streets.update_street(street, street_params),
     %Street{} = street = Streets.preload_aliases(street) do
      render(conn, "show.json", street: street)
    end
  end

  def delete(conn, %{"id" => id}) do
    street = Streets.get_street!(id)
    with {:ok, %Street{}} <- Streets.delete_street(street) do
      send_resp(conn, :no_content, "")
    end
  end

  def search(conn, params) do
    settlement_name = Map.get(params, "street_name", "")

    with changeset = %Ecto.Changeset{valid?: true} <- Streets.search_changeset(params) do
      streets =
        :streets
        |> :ets.match_object(get_match_pattern(changeset.changes))
        |> Enum.filter(fn {_, _, _, _, _, name, _, _, _,} ->
          String.contains?(name, String.downcase(settlement_name)) end)
        |> List.foldl([], fn ({street_id, _, _, _, _, _, _, _, _,}, acc) -> acc ++ [street_id] end)
        |> Streets.list_by_ids()

        render(conn, "search.json", streets: streets)
    end
  end

  defp get_match_pattern(%{settlement_id: settlement_id} = changes) do
    {:"$1", settlement_id, :"$3", :"$4", :"$5", :"$6",
      get_street_type(changes), get_street_number(changes), get_postal_code(changes)}
  end

  defp get_match_pattern(changes) do
    {:"$1", :"$2", get_region_name(changes), get_district_name(changes), get_settlement_name(changes), :"$6",
    get_street_type(changes), get_street_number(changes), get_postal_code(changes)}
  end

  defp get_region_name(%{region_name: region_name}), do: String.downcase(region_name)
  defp get_region_name(_), do: :"$3"

  defp get_district_name(%{district_name: district_name}), do: String.downcase(district_name)
  defp get_district_name(_), do: :"$4"

  defp get_settlement_name(%{settlement_name: settlement_name}), do: String.downcase(settlement_name)
  defp get_settlement_name(_), do: :"$5"

  defp get_street_type(%{street_type: street_type}), do: String.downcase(street_type)
  defp get_street_type(_), do: :"$7"

  defp get_street_number(%{street_number: street_number}), do: String.downcase(street_number)
  defp get_street_number(_), do: :"$8"

  defp get_postal_code(%{postal_code: postal_code}), do: String.downcase(postal_code)
  defp get_postal_code(_), do: :"$9"

end
