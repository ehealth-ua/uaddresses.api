defmodule Uaddresses.Web.RegionControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Areas.Area

  @create_attrs %{name: "some region", koatuu: "1"}
  @update_attrs %{name: "some updated region", koatuu: "1"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates region and renders region when data is valid", %{conn: conn} do
    conn = post(conn, region_path(conn, :create), region: @create_attrs)
    assert %{"id" => id, "name" => "some region"} = json_response(conn, 201)["data"]

    conn = get(conn, region_path(conn, :show, id))
    assert json_response(conn, 200)["data"] == %{"id" => id, "name" => "some region", "koatuu" => "1"}
  end

  test "does not create region and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, region_path(conn, :create), region: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen region and renders region when data is valid", %{conn: conn} do
    %Area{id: id} = area = fixture(:area)
    conn = put(conn, region_path(conn, :update, area), region: @update_attrs)
    assert %{"id" => ^id, "name" => "some updated region"} = json_response(conn, 200)["data"]

    conn = get(conn, region_path(conn, :show, id))
    assert json_response(conn, 200)["data"] == %{"id" => id, "name" => "some updated region", "koatuu" => "1"}
  end

  test "does not update chosen region and renders errors when data is invalid", %{conn: conn} do
    area = fixture(:area)
    conn = put(conn, region_path(conn, :update, area), region: @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  describe "list districts" do
    setup %{conn: conn} do
      %{id: area_id} = area()
      region_1 = region(%{name: "First region", area_id: area_id})
      region_2 = region(%{name: "Second region", area_id: area_id})
      region_3 = region(%{name: "Third region", area_id: area_id})
      %{conn: conn, area_id: area_id, regions: {region_1, region_2, region_3}}
    end

    test "list", %{conn: conn, area_id: area_id, regions: {region_1, region_2, region_3}} do
      conn = get(conn, "/regions/#{area_id}/districts")

      assert json_response(conn, 200)["data"] == [
               %{"id" => region_1.id, "district" => "First region"},
               %{"id" => region_2.id, "district" => "Second region"},
               %{"id" => region_3.id, "district" => "Third region"}
             ]

      conn = get(conn, "/regions/#{area_id}/districts?page_size=1&page=3")

      assert json_response(conn, 200)["data"] == [
               %{"id" => region_3.id, "district" => "Third region"}
             ]

      conn = get(conn, "/regions/#{area_id}/districts?name=ond")

      assert json_response(conn, 200)["data"] == [
               %{"id" => region_2.id, "district" => "Second region"}
             ]
    end

    test "legacy", %{conn: conn, area_id: area_id, regions: {region_1, region_2, region_3}} do
      conn = get(conn, "/details/region/#{area_id}/districts")

      assert json_response(conn, 200)["data"] == [
               %{"id" => region_1.id, "district" => "First region"},
               %{"id" => region_2.id, "district" => "Second region"},
               %{"id" => region_3.id, "district" => "Third region"}
             ]

      conn = get(conn, "/details/region/#{area_id}/districts?page_size=1&page=3")

      assert json_response(conn, 200)["data"] == [
               %{"id" => region_3.id, "district" => "Third region"}
             ]

      conn = get(conn, "/details/region/#{area_id}/districts?name=ond")

      assert json_response(conn, 200)["data"] == [
               %{"id" => region_2.id, "district" => "Second region"}
             ]
    end
  end

  test "search", %{conn: conn} do
    a_1 = area(%{name: "Одеська", koatuu: "11"})
    a_2 = area(%{name: "Дніпропетровська", koatuu: "12"})
    a_3 = area(%{name: "Київська", koatuu: "13"})
    a_4 = area(%{name: "Київ", koatuu: "14"})
    a_5 = area(%{name: "Івано-Франківська", koatuu: "15"})

    conn = get(conn, "/regions/?name=ки")

    assert json_response(conn, 200)["data"] == [
             %{"id" => a_3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => a_4.id, "name" => "Київ", "koatuu" => "14"}
           ]

    conn = get(conn, "/regions/?name=-")

    assert json_response(conn, 200)["data"] == [
             %{"id" => a_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]

    conn = get(conn, "/regions/?name=ська")

    assert json_response(conn, 200)["data"] == [
             %{"id" => a_1.id, "name" => "Одеська", "koatuu" => "11"},
             %{"id" => a_2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
             %{"id" => a_3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => a_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]

    conn = get(conn, "/regions/?name=ська&koatuu=1")

    assert json_response(conn, 200)["data"] == [
             %{"id" => a_1.id, "name" => "Одеська", "koatuu" => "11"},
             %{"id" => a_2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
             %{"id" => a_3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => a_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]

    conn = get(conn, "/regions/?name=ська&koatuu=3")

    assert json_response(conn, 200)["data"] == [
             %{"id" => a_3.id, "name" => "Київська", "koatuu" => "13"}
           ]

    conn = get(conn, "/regions/")

    assert json_response(conn, 200)["data"] == [
             %{"id" => a_1.id, "name" => "Одеська", "koatuu" => "11"},
             %{"id" => a_2.id, "name" => "Дніпропетровська", "koatuu" => "12"},
             %{"id" => a_3.id, "name" => "Київська", "koatuu" => "13"},
             %{"id" => a_4.id, "name" => "Київ", "koatuu" => "14"},
             %{"id" => a_5.id, "name" => "Івано-Франківська", "koatuu" => "15"}
           ]
  end
end
