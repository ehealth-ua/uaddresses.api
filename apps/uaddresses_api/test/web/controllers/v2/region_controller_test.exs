defmodule Uaddresses.Web.V2.RegionControllerTest do
  use Uaddresses.Web.ConnCase

  alias Ecto.UUID

  test "search region settlements", %{conn: conn} do
    area = insert(:area, name: "Area name")
    area2 = insert(:area)

    region = insert(:region, area: area)
    region2 = insert(:region, name: "Region name 2", area: area2)

    first = insert(:settlement, name: "First settlement", region: region, area: area)
    second = insert(:settlement, name: "Second settlement", region: region, area: area)
    third = insert(:settlement, name: "Third settlement", region: region, area: area)
    _fourth = insert(:settlement, name: "Forth settlement", region: region2, area: area2)

    conn = get(conn, v2_region_path(conn, :settlements, region.id))

    assert json_response(conn, 200)["data"] == [
             %{"id" => first.id, "settlement_name" => "First settlement"},
             %{"id" => second.id, "settlement_name" => "Second settlement"},
             %{"id" => third.id, "settlement_name" => "Third settlement"}
           ]

    conn = get(conn, v2_region_path(conn, :settlements, region.id, page_size: 1, page: 2))
    assert json_response(conn, 200)["data"] == [%{"id" => second.id, "settlement_name" => "Second settlement"}]

    conn = get(conn, v2_region_path(conn, :settlements, region.id, name: "ond"))
    assert json_response(conn, 200)["data"] == [%{"id" => second.id, "settlement_name" => "Second settlement"}]
  end

  test "search regions", %{conn: conn} do
    area1 = insert(:area, name: "Київ", koatuu: "1")
    area2 = insert(:area, name: "Одеська", koatuu: "1")
    region1 = insert(:region, area: area1, name: "Дарницький", koatuu: "11")
    region2 = insert(:region, area: area1, name: "Подільський", koatuu: "12")
    region3 = insert(:region, area: area2, name: "Миколаївський", koatuu: "13")
    region4 = insert(:region, area: area2, name: "Комінтернівський", koatuu: "14")

    response_data = get_response_data(conn, v2_region_path(conn, :index))

    assert response_data == [
             %{"id" => region1.id, "name" => "Дарницький", "area" => "Київ", "area_id" => area1.id, "koatuu" => "11"},
             %{"id" => region2.id, "name" => "Подільський", "area" => "Київ", "area_id" => area1.id, "koatuu" => "12"},
             %{
               "id" => region3.id,
               "name" => "Миколаївський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "13"
             },
             %{
               "id" => region4.id,
               "name" => "Комінтернівський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "14"
             }
           ]

    response_data = get_response_data(conn, v2_region_path(conn, :index, area: "київ"))

    expected_regions = [
      %{"id" => region1.id, "name" => "Дарницький", "area" => "Київ", "area_id" => area1.id, "koatuu" => "11"},
      %{"id" => region2.id, "name" => "Подільський", "area" => "Київ", "area_id" => area1.id, "koatuu" => "12"}
    ]

    for region <- expected_regions, do: assert(region in response_data)

    response_data = get_response_data(conn, v2_region_path(conn, :index, area: "київ", page_size: 1))
    assert response_data |> hd() |> Kernel.in(expected_regions)

    response_data = get_response_data(conn, v2_region_path(conn, :index, area: "київ", page_size: 1, page: 2))
    assert response_data |> hd() |> Kernel.in(expected_regions)

    response_data = get_response_data(conn, v2_region_path(conn, :index, area: "київ", area_id: area2.id))

    assert response_data == [
             %{
               "id" => region3.id,
               "name" => "Миколаївський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "13"
             },
             %{
               "id" => region4.id,
               "name" => "Комінтернівський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "14"
             }
           ]

    response_data = get_response_data(conn, v2_region_path(conn, :index, name: "інтерні"))

    assert response_data == [
             %{
               "id" => region4.id,
               "name" => "Комінтернівський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "14"
             }
           ]

    response_data = get_response_data(conn, v2_region_path(conn, :index, koatuu: 1))

    assert response_data == [
             %{"id" => region1.id, "name" => "Дарницький", "area" => "Київ", "area_id" => area1.id, "koatuu" => "11"},
             %{"id" => region2.id, "name" => "Подільський", "area" => "Київ", "area_id" => area1.id, "koatuu" => "12"},
             %{
               "id" => region3.id,
               "name" => "Миколаївський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "13"
             },
             %{
               "id" => region4.id,
               "name" => "Комінтернівський",
               "area" => "Одеська",
               "area_id" => area2.id,
               "koatuu" => "14"
             }
           ]

    response_data = get_response_data(conn, v2_region_path(conn, :index, koatuu: 2))

    assert response_data == [
             %{"id" => region2.id, "name" => "Подільський", "area" => "Київ", "area_id" => area1.id, "koatuu" => "12"}
           ]
  end

  test "show region", %{conn: conn} do
    region = insert(:region, name: "Region one", koatuu: "8")

    resp_entity =
      conn
      |> get(v2_region_path(conn, :show, region.id))
      |> json_response(200)
      |> Map.get("data")

    assert %{
             "area" => region.area.name,
             "area_id" => region.area_id,
             "id" => region.id,
             "koatuu" => "8",
             "name" => "Region one"
           } == resp_entity
  end

  test "not found region", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> get(v2_region_path(conn, :show, UUID.generate()))
      |> json_response(404)
    end
  end

  defp get_response_data(conn, url) do
    conn = get(conn, url)
    json_response(conn, 200)["data"]
  end
end
