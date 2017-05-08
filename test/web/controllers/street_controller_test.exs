defmodule Uaddresses.Web.StreetControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Streets.Street

  @create_attrs %{district_id: "7488a646-e31f-11e4-aace-600308960662", postal_code: "some postal_code", region_id: "7488a646-e31f-11e4-aace-600308960662", settlement_id: "7488a646-e31f-11e4-aace-600308960662", street_name: "some street_name", street_number: "some street_number", street_type: "some street_type"}
  @update_attrs %{district_id: "7488a646-e31f-11e4-aace-600308960668", postal_code: "some updated postal_code", region_id: "7488a646-e31f-11e4-aace-600308960668", settlement_id: "7488a646-e31f-11e4-aace-600308960668", street_name: "some updated street_name", street_number: "some updated street_number", street_type: "some updated street_type"}
  @invalid_attrs %{district_id: nil, postal_code: nil, region_id: nil, settlement_id: nil, street_name: nil, street_number: nil, street_type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, street_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates street and renders street when data is valid", %{conn: conn} do
    %{id: region_id} = region()
    %{id: district_id} = district()
    %{id: settlement_id} = settlement()
    create_attrs =
      Map.merge(@create_attrs, %{region_id: region_id, district_id: district_id, settlement_id: settlement_id})

    conn = post conn, street_path(conn, :create), street: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, street_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "district_id" => district_id,
      "postal_code" => "some postal_code",
      "region_id" => region_id,
      "settlement_id" => settlement_id,
      "street_name" => "some street_name",
      "street_number" => "some street_number",
      "street_type" => "some street_type", "type" => "street"}
  end

  test "does not create street and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, street_path(conn, :create), street: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen street and renders street when data is valid", %{conn: conn} do
    %Street{id: id} = street = fixture(:street)
    %{id: region_id} = region()
    %{id: district_id} = district()
    %{id: settlement_id} = settlement()
    update_attrs =
      Map.merge(@update_attrs, %{region_id: region_id, district_id: district_id, settlement_id: settlement_id})

    conn = put conn, street_path(conn, :update, street), street: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, street_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "district_id" => district_id,
      "postal_code" => "some updated postal_code",
      "region_id" => region_id,
      "settlement_id" => settlement_id,
      "street_name" => "some updated street_name",
      "street_number" => "some updated street_number",
      "street_type" => "some updated street_type", "type" => "street"}
  end

  test "does not update chosen street and renders errors when data is invalid", %{conn: conn} do
    street = fixture(:street)
    conn = put conn, street_path(conn, :update, street), street: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen street", %{conn: conn} do
    street = fixture(:street)
    conn = delete conn, street_path(conn, :delete, street)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, street_path(conn, :show, street)
    end
  end
end
