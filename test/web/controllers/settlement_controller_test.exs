defmodule Uaddresses.Web.SettlementControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Settlements.Settlement

  @create_attrs %{
    district_id: "7488a646-e31f-11e4-aace-600308960662",
    name: "some name",
    region_id: "7488a646-e31f-11e4-aace-600308960662"
  }

  @update_attrs %{
    district_id: "7488a646-e31f-11e4-aace-600308960668",
    name: "some updated name",
    region_id: "7488a646-e31f-11e4-aace-600308960668"
  }

  @invalid_attrs %{
    district_id: nil,
    name: nil,
    region_id: nil
  }


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

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Київська"})
    r_2 = region(%{name: "Одеська"})
    d_1 = district(%{region_id: r_1.id, name: "Білоцерківський"})
    d_2 = district(%{region_id: r_1.id, name: "Рокитнянський"})
    d_3 = district(%{region_id: r_2.id, name: "Миколаївський"})
    d_4 = district(%{region_id: r_2.id, name: "Комінтернівський"})

    settlement(%{region_id: r_1.id, district_id: d_2.id, name: "Рокитне"})
    s_2 = settlement(%{region_id: r_1.id, district_id: d_2.id, name: "Бакумівка"})

    s_3 = settlement(%{region_id: r_1.id, district_id: d_1.id, name: "Володарка"})
    s_4 = settlement(%{region_id: r_1.id, district_id: d_1.id, name: "Біла Церква"})

    settlement(%{region_id: r_2.id, district_id: d_3.id, name: "Миколаївка"})
    s_6 = settlement(%{region_id: r_2.id, district_id: d_3.id, name: "Якесь село"})

    s_7 = settlement(%{region_id: r_2.id, district_id: d_4.id, name: "Комінтерне"})
    s_8 = settlement(%{region_id: r_2.id, district_id: d_4.id, name: "Новосілки 2"})

    conn = get conn, "/search/settlements/"
    assert json_response(conn, 422)

    conn = get conn, "/search/settlements/?region=Київська&settlement_name=а"

    assert json_response(conn, 200)["data"] == [
      %{"district" => "Рокитнянський", "id" => s_2.id,
        "region" => "Київська", "settlement_name" => "Бакумівка"},
      %{"district" => "Білоцерківський", "id" => s_3.id,
        "region" => "Київська", "settlement_name" => "Володарка"},
      %{"district" => "Білоцерківський", "id" => s_4.id,
        "region" => "Київська", "settlement_name" => "Біла Церква"}
    ]

    conn = get conn, "/search/settlements/?region=Одеська&district=Комінтернівський"
    assert json_response(conn, 200)["data"] == [
      %{"district" => "Комінтернівський", "id" => s_7.id,
        "region" => "Одеська", "settlement_name" => "Комінтерне"},
      %{"district" => "Комінтернівський", "id" => s_8.id,
        "region" => "Одеська", "settlement_name" => "Новосілки 2"},
    ]

    conn = get conn, "/search/settlements/?region=Одеська&settlement_name=Якесь село"
    assert json_response(conn, 200)["data"] == [
      %{"district" => "Миколаївський", "id" => s_6.id,
        "region" => "Одеська", "settlement_name" => "Якесь село"},
    ]

  end
end
