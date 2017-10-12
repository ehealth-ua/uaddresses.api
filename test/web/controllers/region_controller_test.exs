defmodule Uaddresses.Web.RegionControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Regions.Region

  @create_attrs %{name: "some region", koatuu: "1"}
  @update_attrs %{name: "some updated region", koatuu: "1"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates region and renders region when data is valid", %{conn: conn} do
    conn = post conn, region_path(conn, :create), region: @create_attrs
    assert %{"id" => id, "name" => "some region"} = json_response(conn, 201)["data"]

    conn = get conn, region_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{"id" => id, "name" => "some region", "koatuu" => "1"}
  end

  test "does not create region and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, region_path(conn, :create), region: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen region and renders region when data is valid", %{conn: conn} do
    %Region{id: id} = region = fixture(:region)
    conn = put conn, region_path(conn, :update, region), region: @update_attrs
    assert %{"id" => ^id, "name" => "some updated region"} = json_response(conn, 200)["data"]

    conn = get conn, region_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{"id" => id, "name" => "some updated region", "koatuu" => "1"}
  end

  test "does not update chosen region and renders errors when data is invalid", %{conn: conn} do
    region = fixture(:region)
    conn = put conn, region_path(conn, :update, region), region: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "list districts", %{conn: conn} do
    %{id: region_id} = region()
    first_district = district(%{name: "First district", region_id: region_id})
    second_district = district(%{name: "Second district", region_id: region_id})
    third_district = district(%{name: "Third district", region_id: region_id})

    conn = get conn, "/details/region/#{region_id}/districts"
    assert json_response(conn, 200)["data"] == [
      %{"id" => first_district.id, "district" => "First district"},
      %{"id" => second_district.id, "district" => "Second district"},
      %{"id" => third_district.id, "district" => "Third district"}
    ]

    conn = get conn, "/details/region/#{region_id}/districts?page_size=1&page=3"
    assert json_response(conn, 200)["data"] == [
      %{"id" => third_district.id, "district" => "Third district"}
    ]

    conn = get conn, "/details/region/#{region_id}/districts?name=ond"
    assert json_response(conn, 200)["data"] == [
      %{"id" => second_district.id, "district" => "Second district"},
    ]
  end

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Одеська", koatuu: "11"})
    r_2 = region(%{name: "Дніпропетровська", koatuu: "12"})
    r_3 = region(%{name: "Київська", koatuu: "13"})
    r_4 = region(%{name: "Київ", koatuu: "14"})
    r_5 = region(%{name: "Івано-Франківська", koatuu: "15"})

    conn = get conn, "/regions/?name=ки"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_3.id, "name" => "Київська", "koatuu" => "13"},
      %{"id" => r_4.id, "name" => "Київ", "koatuu" => "14"}
    ]

    conn = get conn, "/regions/?name=-"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
    ]

    conn = get conn, "/regions/?name=ська"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_1.id, "name" => "Одеська", "koatuu" => "11"},
      %{"id" => r_2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
      %{"id" => r_3.id, "name" => "Київська", "koatuu" => "13"},
      %{"id" => r_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
    ]

    conn = get conn, "/regions/?name=ська&koatuu=1"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_1.id, "name" => "Одеська", "koatuu" => "11"},
      %{"id" => r_2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
      %{"id" => r_3.id, "name" => "Київська", "koatuu" => "13"},
      %{"id" => r_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
    ]

    conn = get conn, "/regions/?name=ська&koatuu=3"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_3.id, "name" => "Київська", "koatuu" => "13"}
    ]

    conn = get conn, "/regions/"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_1.id, "name" => "Одеська", "koatuu" => "11"},
      %{"id" => r_2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
      %{"id" => r_3.id, "name" => "Київська", "koatuu" => "13"},
      %{"id" => r_4.id, "name" => "Київ", "koatuu" => "14"},
      %{"id" => r_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
    ]
  end
end
