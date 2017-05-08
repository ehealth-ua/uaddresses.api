defmodule Uaddresses.Web.RegionControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Regions.Region

  @create_attrs %{name: "some region"}
  @update_attrs %{name: "some updated region"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, region_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates region and renders region when data is valid", %{conn: conn} do
    conn = post conn, region_path(conn, :create), region: @create_attrs
    assert %{"id" => id, "type" => "region", "name" => "some region"} = json_response(conn, 201)["data"]

    conn = get conn, region_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{"id" => id, "type" => "region", "name" => "some region"}
  end

  test "does not create region and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, region_path(conn, :create), region: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen region and renders region when data is valid", %{conn: conn} do
    %Region{id: id} = region = fixture(:region)
    conn = put conn, region_path(conn, :update, region), region: @update_attrs
    assert %{"id" => ^id, "type" => "region", "name" => "some updated region"} = json_response(conn, 200)["data"]

    conn = get conn, region_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{"id" => id, "type" => "region", "name" => "some updated region"}
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

    conn = get conn, "/details/region/#{region_id}/districts"
    assert json_response(conn, 200)["data"] == [
      %{"id" => first_district.id, "district" => "First district"},
      %{"id" => second_district.id, "district" => "Second district"}
    ]
  end

  test "search by region name", %{conn: conn} do
    r_1 = region(%{name: "Одеська"})
    r_2 = region(%{name: "Дніпропетровська"})
    r_3 = region(%{name: "Київська"})
    r_4 = region(%{name: "Київ"})
    r_5 = region(%{name: "Івано-Франківська"})

    conn = get conn, "/search/regions/?region=ки"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_3.id, "name" => "Київська"},
      %{"id" => r_4.id, "name" => "Київ"}
    ]

    conn = get conn, "/search/regions/?region=-"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_5.id, "name" => "Івано-Франківська"}
    ]

    conn = get conn, "/search/regions/?region=ська"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_1.id, "name" => "Одеська"},
      %{"id" => r_2.id, "name" => "Дніпропетровська"},
      %{"id" => r_3.id, "name" => "Київська"},
      %{"id" => r_5.id, "name" => "Івано-Франківська"}
    ]

    conn = get conn, "/search/regions/"
    assert json_response(conn, 200)["data"] == [
      %{"id" => r_1.id, "name" => "Одеська"},
      %{"id" => r_2.id, "name" => "Дніпропетровська"},
      %{"id" => r_3.id, "name" => "Київська"},
      %{"id" => r_4.id, "name" => "Київ"},
      %{"id" => r_5.id, "name" => "Івано-Франківська"}
    ]
  end
end
