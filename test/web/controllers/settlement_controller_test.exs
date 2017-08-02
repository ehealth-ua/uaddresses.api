defmodule Uaddresses.Web.SettlementControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Settlements.Settlement

  @create_attrs %{
    type: "1",
    district_id: "7488a646-e31f-11e4-aace-600308960662",
    name: "some name",
    region_id: "7488a646-e31f-11e4-aace-600308960662",
    mountain_group: false,
    koatuu: "1"
  }

  @update_attrs %{
    type: "1",
    district_id: "7488a646-e31f-11e4-aace-600308960668",
    name: "some updated name",
    region_id: "7488a646-e31f-11e4-aace-600308960668",
    mountain_group: true,
    koatuu: "1"
  }

  @invalid_attrs %{
    district_id: nil,
    name: nil,
    region_id: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates settlement and renders settlement when data is valid", %{conn: conn} do
    %{id: region_id} = region()
    %{id: district_id} = district(%{region_id: region_id, name: "some name"})
    create_attrs = Map.merge(@create_attrs, %{region_id: region_id, district_id: district_id})

    conn = post conn, settlement_path(conn, :create), settlement: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, settlement_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "type" => "1",
      "id" => id,
      "district" => "some name",
      "district_id" => district_id,
      "name" => "some name",
      "region" => "some region",
      "region_id" => region_id,
      "mountain_group" => false,
      "koatuu" => "1",
      "parent_settlement" => nil,
      "parent_settlement_id" => nil
    }
  end

  test "does not create settlement and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, settlement_path(conn, :create), settlement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen settlement and renders settlement when data is valid", %{conn: conn} do
    %Settlement{id: id} = settlement = fixture(:settlement)
    region_id = settlement.region.id
    district_id = settlement.district.id
    update_attrs = Map.merge(@update_attrs, %{region_id: region_id, district_id: district_id})

    conn = put conn, settlement_path(conn, :update, settlement), settlement: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, settlement_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "type" => "1",
      "id" => id,
      "district" => "some name",
      "district_id" => district_id,
      "name" => "some updated name",
      "region" => "some region",
      "region_id" => region_id,
      "mountain_group" => true,
      "koatuu" => "1",
      "parent_settlement" => nil,
      "parent_settlement_id" => nil
    }
  end

  test "does not update chosen settlement and renders errors when data is invalid", %{conn: conn} do
    settlement = fixture(:settlement)
    conn = put conn, settlement_path(conn, :update, settlement), settlement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Київська", koatuu: "1"})
    r_2 = region(%{name: "Одеська", koatuu: "1"})
    d_1 = district(%{region_id: r_1.id, name: "Білоцерківський"})
    d_2 = district(%{region_id: r_1.id, name: "Рокитнянський"})
    d_3 = district(%{region_id: r_2.id, name: "Миколаївський"})
    d_4 = district(%{region_id: r_2.id, name: "Комінтернівський"})

    s_1 = settlement(%{region_id: r_1.id, district_id: d_2.id, name: "Рокитне", type: "1", koatuu: "11",
      mountain_group: false})
    s_2 = settlement(%{region_id: r_1.id, district_id: d_2.id, name: "Бакумівка", type: "2", koatuu: "12",
      mountain_group: true})

    s_3 = settlement(%{region_id: r_1.id, district_id: d_1.id, name: "Володарка", type: "3", koatuu: "13",
      mountain_group: false})
    s_4 = settlement(%{region_id: r_1.id, district_id: d_1.id, name: "Біла Церква", type: "4", koatuu: "14",
      mountain_group: false})

    s_5 = settlement(%{region_id: r_2.id, district_id: d_3.id, name: "Миколаївка", type: "5", koatuu: "15",
      mountain_group: false})
    s_6 = settlement(%{region_id: r_2.id, district_id: d_3.id, name: "Якесь село", type: "6", koatuu: "16",
      mountain_group: false})

    s_7 = settlement(%{region_id: r_2.id, district_id: d_4.id, name: "Комінтерне", type: "7", koatuu: "17",
      mountain_group: false})
    s_8 = settlement(%{region_id: r_2.id, district_id: d_4.id, name: "Новосілки 2", type: "8", koatuu: "18",
      mountain_group: true})

    conn = get conn, "/settlements/"
    assert response = json_response(conn, 200)["data"]
    assert 8 == Enum.count(response)
    assert [
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_1.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Рокитне", "mountain_group" => false,
        "type" => "1", "koatuu" => "11", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_2.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Бакумівка", "mountain_group" => true,
        "type" => "2", "koatuu" => "12", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "district_id" => d_1.id, "id" => s_3.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Володарка", "mountain_group" => false,
        "type" => "3", "koatuu" => "13", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "region_id" => r_1.id, "district_id" => d_1.id, "id" => s_4.id,
        "region" => "Київська", "name" => "Біла Церква", "mountain_group" => false,
        "type" => "4", "koatuu" => "14", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_5.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Миколаївка", "mountain_group" => false,
        "type" => "5", "koatuu" => "15", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_6.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Якесь село", "mountain_group" => false,
        "type" => "6", "koatuu" => "16", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_7.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Комінтерне", "mountain_group" => false,
        "type" => "7", "koatuu" => "17", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_8.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Новосілки 2", "mountain_group" => true,
        "type" => "8", "koatuu" => "18", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?region=київська&name=а"

    assert response = json_response(conn, 200)["data"]
    assert 3 == Enum.count(response)
    assert [
      %{"district" => "Білоцерківський", "region_id" => r_1.id, "district_id" => d_1.id, "id" => s_4.id,
        "region" => "Київська", "name" => "Біла Церква", "mountain_group" => false,
        "type" => "4", "koatuu" => "14", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "district_id" => d_1.id, "id" => s_3.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Володарка", "mountain_group" => false,
        "type" => "3", "koatuu" => "13", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_2.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Бакумівка", "mountain_group" => true,
        "type" => "2", "koatuu" => "12", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?region=одеська&district=комінтернівський"
    assert response = json_response(conn, 200)["data"]
    assert 2 == Enum.count(response)
    assert [
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_7.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Комінтерне", "mountain_group" => false,
        "type" => "7", "koatuu" => "17", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_8.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Новосілки 2", "mountain_group" => true,
        "type" => "8", "koatuu" => "18", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?region=одеська&name=Якесь село"
    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)
    [
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_6.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Якесь село", "mountain_group" => false,
        "type" => "6", "koatuu" => "16", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?type=4"
    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)
    assert [
      %{"district" => "Білоцерківський", "region_id" => r_1.id, "district_id" => d_1.id, "id" => s_4.id,
        "region" => "Київська", "name" => "Біла Церква", "mountain_group" => false,
        "type" => "4", "koatuu" => "14", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?koatuu=1"
    assert response = json_response(conn, 200)["data"]
    assert 8 == Enum.count(response)
    assert [
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_1.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Рокитне", "mountain_group" => false,
        "type" => "1", "koatuu" => "11", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_2.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Бакумівка", "mountain_group" => true,
        "type" => "2", "koatuu" => "12", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "district_id" => d_1.id, "id" => s_3.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Володарка", "mountain_group" => false,
        "type" => "3", "koatuu" => "13", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "region_id" => r_1.id, "district_id" => d_1.id, "id" => s_4.id,
        "region" => "Київська", "name" => "Біла Церква", "mountain_group" => false,
        "type" => "4", "koatuu" => "14", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_5.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Миколаївка", "mountain_group" => false,
        "type" => "5", "koatuu" => "15", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_6.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Якесь село", "mountain_group" => false,
        "type" => "6", "koatuu" => "16", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_7.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Комінтерне", "mountain_group" => false,
        "type" => "7", "koatuu" => "17", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_8.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Новосілки 2", "mountain_group" => true,
        "type" => "8", "koatuu" => "18", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?koatuu=5"
    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)
    assert [
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_5.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Миколаївка", "mountain_group" => false,
        "type" => "5", "koatuu" => "15", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?mountain_group=true"
    assert response = json_response(conn, 200)["data"]
    assert 2 == Enum.count(response)
    assert [
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_2.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Бакумівка", "mountain_group" => true,
        "type" => "2", "koatuu" => "12", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_8.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Новосілки 2", "mountain_group" => true,
        "type" => "8", "koatuu" => "18", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?

    conn = get conn, "/settlements/?mountain_group=false"
    assert response = json_response(conn, 200)["data"]
    assert 6 == Enum.count(response)
    assert [
      %{"district" => "Рокитнянський", "district_id" => d_2.id, "id" => s_1.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Рокитне", "mountain_group" => false,
        "type" => "1", "koatuu" => "11", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "district_id" => d_1.id, "id" => s_3.id,
        "region" => "Київська", "region_id" => r_1.id, "name" => "Володарка", "mountain_group" => false,
        "type" => "3", "koatuu" => "13", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Білоцерківський", "region_id" => r_1.id, "district_id" => d_1.id, "id" => s_4.id,
        "region" => "Київська", "name" => "Біла Церква", "mountain_group" => false,
        "type" => "4", "koatuu" => "14", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_5.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Миколаївка", "mountain_group" => false,
        "type" => "5", "koatuu" => "15", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Миколаївський", "district_id" => d_3.id, "id" => s_6.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Якесь село", "mountain_group" => false,
        "type" => "6", "koatuu" => "16", "parent_settlement" => nil, "parent_settlement_id" => nil},
      %{"district" => "Комінтернівський", "district_id" => d_4.id, "id" => s_7.id,
        "region" => "Одеська", "region_id" => r_2.id, "name" => "Комінтерне", "mountain_group" => false,
        "type" => "7", "koatuu" => "17", "parent_settlement" => nil, "parent_settlement_id" => nil}
    ]
    |> Enum.map(&(Enum.member?(response, &1)))
    |> Enum.all?
  end
end
