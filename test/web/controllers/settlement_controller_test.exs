defmodule Uaddresses.Web.SettlementControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Settlements.Settlement

  @create_attrs %{district_id: "7488a646-e31f-11e4-aace-600308960662", name: "some name", region_id: "7488a646-e31f-11e4-aace-600308960662"}
  @update_attrs %{district_id: "7488a646-e31f-11e4-aace-600308960668", name: "some updated name", region_id: "7488a646-e31f-11e4-aace-600308960668"}
  @invalid_attrs %{district_id: nil, name: nil, region_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, settlement_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates settlement and renders settlement when data is valid", %{conn: conn} do
    %{id: region_id} = region()
    %{id: district_id} = district()
    create_attrs = Map.merge(@create_attrs, %{region_id: region_id, district_id: district_id})

    conn = post conn, settlement_path(conn, :create), settlement: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, settlement_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "district_id" => district_id,
      "name" => "some name",
      "region_id" => region_id,
      "type" => "settlement"}
  end

  test "does not create settlement and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, settlement_path(conn, :create), settlement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen settlement and renders settlement when data is valid", %{conn: conn} do
    %Settlement{id: id} = settlement = fixture(:settlement)
    %{id: region_id} = region()
    %{id: district_id} = district()
    update_attrs = Map.merge(@update_attrs, %{region_id: region_id, district_id: district_id})

    conn = put conn, settlement_path(conn, :update, settlement), settlement: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, settlement_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "district_id" => district_id,
      "name" => "some updated name",
      "region_id" => region_id,
      "type" => "settlement"}
  end

  test "does not update chosen settlement and renders errors when data is invalid", %{conn: conn} do
    settlement = fixture(:settlement)
    conn = put conn, settlement_path(conn, :update, settlement), settlement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen settlement", %{conn: conn} do
    settlement = fixture(:settlement)
    conn = delete conn, settlement_path(conn, :delete, settlement)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, settlement_path(conn, :show, settlement)
    end
  end
end
