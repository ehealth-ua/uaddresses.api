defmodule Uaddresses.Web.RegionControllerTest do
  use Uaddresses.Web.ConnCase

  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region

  @create_attrs %{name: "some region"}
  @update_attrs %{name: "some updated region"}
  @invalid_attrs %{name: nil}

  def fixture(:region) do
    {:ok, region} = Regions.create_region(@create_attrs)
    region
  end

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

  test "deletes chosen region", %{conn: conn} do
    region = fixture(:region)
    conn = delete conn, region_path(conn, :delete, region)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, region_path(conn, :show, region)
    end
  end
end
