defmodule Uaddresses.Web.DistrictControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Districts.District

  @create_attrs %{name: "some name", region_id: "7488a646-e31f-11e4-aace-600308960662"}
  @update_attrs %{name: "some updated name", region_id: "7488a646-e31f-11e4-aace-600308960668"}
  @invalid_attrs %{name: nil, region_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, district_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates district and renders district when data is valid", %{conn: conn} do
    %{id: region_id} = region()
    create_attrs = Map.put(@create_attrs, :region_id, region_id)

    conn = post conn, district_path(conn, :create), district: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, district_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name",
      "region_id" => region_id,
      "type" => "district"
      }
  end

  test "does not create district and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, district_path(conn, :create), district: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen district and renders district when data is valid", %{conn: conn} do
    %District{id: id} = district = fixture(:district)
    %{id: region_id} = region()
    update_attrs = Map.put(@update_attrs, :region_id, region_id)
    conn = put conn, district_path(conn, :update, district), district: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, district_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name",
      "region_id" => region_id,
      "type" => "district"
      }
  end

  test "does not update chosen district and renders errors when data is invalid", %{conn: conn} do
    district = fixture(:district)
    conn = put conn, district_path(conn, :update, district), district: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen district", %{conn: conn} do
    district = fixture(:district)
    conn = delete conn, district_path(conn, :delete, district)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, district_path(conn, :show, district)
    end
  end
end
