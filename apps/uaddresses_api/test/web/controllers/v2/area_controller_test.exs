defmodule Uaddresses.Web.V2.AreaControllerTest do
  use Uaddresses.Web.ConnCase

  alias Ecto.UUID

  test "list area regions", %{conn: conn} do
    %{id: area_id} = area = insert(:area)
    region_1 = insert(:region, name: "First region", area: area)
    region_2 = insert(:region, name: "Second region", area: area)
    region_3 = insert(:region, name: "Third region", area: area)

    conn = get(conn, v2_area_path(conn, :regions, area_id))

    assert json_response(conn, 200)["data"] == [
             %{"id" => region_1.id, "region" => "First region"},
             %{"id" => region_2.id, "region" => "Second region"},
             %{"id" => region_3.id, "region" => "Third region"}
           ]

    conn = get(conn, v2_area_path(conn, :regions, area_id, page_size: 1, page: 3))

    assert json_response(conn, 200)["data"] == [
             %{"id" => region_3.id, "region" => "Third region"}
           ]

    conn = get(conn, v2_area_path(conn, :regions, area_id, name: "ond"))

    assert json_response(conn, 200)["data"] == [
             %{"id" => region_2.id, "region" => "Second region"}
           ]
  end

  test "search areas", %{conn: conn} do
    area1 = insert(:area, name: "Одеська", koatuu: "11")
    area2 = insert(:area, name: "Дніпропетровська", koatuu: "12")
    area3 = insert(:area, name: "Київська", koatuu: "13")
    area4 = insert(:area, name: "Київ", koatuu: "14")
    area5 = insert(:area, name: "Івано-Франківська", koatuu: "15")

    conn = get(conn, v2_area_path(conn, :index, name: "ки"))

    assert json_response(conn, 200)["data"] == [
             %{"id" => area3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => area4.id, "name" => "Київ", "koatuu" => "14"}
           ]

    conn = get(conn, v2_area_path(conn, :index, name: "-"))

    assert json_response(conn, 200)["data"] == [
             %{"id" => area5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]

    conn = get(conn, v2_area_path(conn, :index, name: "ська"))

    assert json_response(conn, 200)["data"] == [
             %{"id" => area1.id, "name" => "Одеська", "koatuu" => "11"},
             %{"id" => area2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
             %{"id" => area3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => area5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]

    conn = get(conn, v2_area_path(conn, :index, name: "ська", koatuu: "1"))

    assert json_response(conn, 200)["data"] == [
             %{"id" => area1.id, "name" => "Одеська", "koatuu" => "11"},
             %{"id" => area2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
             %{"id" => area3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => area5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]

    conn = get(conn, v2_area_path(conn, :index, name: "ська", koatuu: "3"))

    assert json_response(conn, 200)["data"] == [
             %{"id" => area3.id, "name" => "Київська", "koatuu" => "13"}
           ]

    conn = get(conn, v2_area_path(conn, :index))

    assert json_response(conn, 200)["data"] == [
             %{"id" => area1.id, "name" => "Одеська", "koatuu" => "11"},
             %{"id" => area2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
             %{"id" => area3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => area4.id, "name" => "Київ", "koatuu" => "14"},
             %{"id" => area5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]
  end

  test "show area", %{conn: conn} do
    %{id: area_id} = insert(:area, koatuu: "2", name: "Area one")

    resp_entity =
      conn
      |> get(v2_area_path(conn, :show, area_id))
      |> json_response(200)
      |> Map.get("data")

    assert %{
             "id" => area_id,
             "koatuu" => "2",
             "name" => "Area one"
           } == resp_entity
  end

  test "not found area", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> get(v2_area_path(conn, :show, UUID.generate()))
      |> json_response(404)
    end
  end
end
