defmodule Uaddresses.Web.V2.SettlementControllerTest do
  use Uaddresses.Web.ConnCase

  alias Ecto.UUID

  test "search", %{conn: conn} do
    area1 = insert(:area, name: "Київська", koatuu: "1")
    area2 = insert(:area, name: "Одеська", koatuu: "1")
    region1 = insert(:region, area: area1, name: "Білоцерківський")
    region2 = insert(:region, area: area1, name: "Рокитнянський")
    region3 = insert(:region, area: area2, name: "Миколаївський")
    region4 = insert(:region, area: area2, name: "Комінтернівський")

    settlement1 =
      insert(:settlement,
        area: area1,
        region: region2,
        name: "Рокитне",
        type: "1",
        koatuu: "11",
        mountain_group: false,
        parent_settlement_id: nil
      )

    settlement2 =
      insert(:settlement,
        area: area1,
        region: region2,
        name: "Бакумівка",
        type: "2",
        koatuu: "12",
        mountain_group: true,
        parent_settlement_id: nil
      )

    settlement3 =
      insert(:settlement,
        area: area1,
        region: region1,
        name: "Володарка",
        type: "3",
        koatuu: "13",
        mountain_group: false,
        parent_settlement_id: nil
      )

    settlement4 =
      insert(:settlement,
        area: area1,
        region: region1,
        name: "Біла Церква",
        type: "4",
        koatuu: "14",
        mountain_group: false,
        parent_settlement_id: nil
      )

    settlement5 =
      insert(:settlement,
        area: area2,
        region: region3,
        name: "Миколаївка",
        type: "5",
        koatuu: "15",
        mountain_group: false,
        parent_settlement_id: nil
      )

    settlement6 =
      insert(:settlement,
        area: area2,
        region: region3,
        name: "Якесь село",
        type: "6",
        koatuu: "16",
        mountain_group: false,
        parent_settlement_id: nil
      )

    settlement7 =
      insert(:settlement,
        area: area2,
        region: region4,
        name: "Комінтерне",
        type: "7",
        koatuu: "17",
        mountain_group: false,
        parent_settlement_id: nil
      )

    settlement8 =
      insert(:settlement,
        area: area2,
        region: region4,
        name: "Новосілки 2",
        type: "8",
        koatuu: "18",
        mountain_group: true,
        parent_settlement_id: nil
      )

    conn = get(conn, v2_settlement_path(conn, :index))
    assert response = json_response(conn, 200)["data"]
    assert 8 == Enum.count(response)

    assert [
             %{
               "region" => "Рокитнянський",
               "region_id" => region2.id,
               "id" => settlement1.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Рокитне",
               "mountain_group" => false,
               "type" => "1",
               "koatuu" => "11",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Рокитнянський",
               "region_id" => region2.id,
               "id" => settlement2.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Бакумівка",
               "mountain_group" => true,
               "type" => "2",
               "koatuu" => "12",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Білоцерківський",
               "region_id" => region1.id,
               "id" => settlement3.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Володарка",
               "mountain_group" => false,
               "type" => "3",
               "koatuu" => "13",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Білоцерківський",
               "area_id" => area1.id,
               "region_id" => region1.id,
               "id" => settlement4.id,
               "area" => "Київська",
               "name" => "Біла Церква",
               "mountain_group" => false,
               "type" => "4",
               "koatuu" => "14",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement5.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Миколаївка",
               "mountain_group" => false,
               "type" => "5",
               "koatuu" => "15",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement6.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Якесь село",
               "mountain_group" => false,
               "type" => "6",
               "koatuu" => "16",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement7.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Комінтерне",
               "mountain_group" => false,
               "type" => "7",
               "koatuu" => "17",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement8.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Новосілки 2",
               "mountain_group" => true,
               "type" => "8",
               "koatuu" => "18",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, area: "київська", name: "воло"))

    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)

    assert [
             %{
               "region" => "Білоцерківський",
               "region_id" => region1.id,
               "id" => settlement3.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Володарка",
               "mountain_group" => false,
               "type" => "3",
               "koatuu" => "13",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, area: "одеська", region: "комінтернівський"))
    assert response = json_response(conn, 200)["data"]
    assert 2 == Enum.count(response)

    assert [
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement7.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Комінтерне",
               "mountain_group" => false,
               "type" => "7",
               "koatuu" => "17",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement8.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Новосілки 2",
               "mountain_group" => true,
               "type" => "8",
               "koatuu" => "18",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, area: "одеська", name: "Якесь село"))
    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)

    [
      %{
        "region" => "Миколаївський",
        "region_id" => region3.id,
        "id" => settlement6.id,
        "area" => "Одеська",
        "area_id" => area2.id,
        "name" => "Якесь село",
        "mountain_group" => false,
        "type" => "6",
        "koatuu" => "16",
        "parent_settlement" => nil,
        "parent_settlement_id" => nil
      }
    ]
    |> Enum.map(&Enum.member?(response, &1))
    |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, type: 4))
    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)

    assert [
             %{
               "region" => "Білоцерківський",
               "area_id" => area1.id,
               "region_id" => region1.id,
               "id" => settlement4.id,
               "area" => "Київська",
               "name" => "Біла Церква",
               "mountain_group" => false,
               "type" => "4",
               "koatuu" => "14",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, koatuu: 1))
    assert response = json_response(conn, 200)["data"]
    assert 8 == Enum.count(response)

    assert [
             %{
               "region" => "Рокитнянський",
               "region_id" => region2.id,
               "id" => settlement1.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Рокитне",
               "mountain_group" => false,
               "type" => "1",
               "koatuu" => "11",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Рокитнянський",
               "region_id" => region2.id,
               "id" => settlement2.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Бакумівка",
               "mountain_group" => true,
               "type" => "2",
               "koatuu" => "12",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Білоцерківський",
               "region_id" => region1.id,
               "id" => settlement3.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Володарка",
               "mountain_group" => false,
               "type" => "3",
               "koatuu" => "13",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Білоцерківський",
               "area_id" => area1.id,
               "region_id" => region1.id,
               "id" => settlement4.id,
               "area" => "Київська",
               "name" => "Біла Церква",
               "mountain_group" => false,
               "type" => "4",
               "koatuu" => "14",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement5.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Миколаївка",
               "mountain_group" => false,
               "type" => "5",
               "koatuu" => "15",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement6.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Якесь село",
               "mountain_group" => false,
               "type" => "6",
               "koatuu" => "16",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement7.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Комінтерне",
               "mountain_group" => false,
               "type" => "7",
               "koatuu" => "17",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement8.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Новосілки 2",
               "mountain_group" => true,
               "type" => "8",
               "koatuu" => "18",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, koatuu: 5))
    assert response = json_response(conn, 200)["data"]
    assert 1 == Enum.count(response)

    assert [
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement5.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Миколаївка",
               "mountain_group" => false,
               "type" => "5",
               "koatuu" => "15",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, mountain_group: true))
    assert response = json_response(conn, 200)["data"]
    assert 2 == Enum.count(response)

    assert [
             %{
               "region" => "Рокитнянський",
               "region_id" => region2.id,
               "id" => settlement2.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Бакумівка",
               "mountain_group" => true,
               "type" => "2",
               "koatuu" => "12",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement8.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Новосілки 2",
               "mountain_group" => true,
               "type" => "8",
               "koatuu" => "18",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()

    conn = get(conn, v2_settlement_path(conn, :index, mountain_group: false))
    assert response = json_response(conn, 200)["data"]
    assert 6 == Enum.count(response)

    assert [
             %{
               "region" => "Рокитнянський",
               "region_id" => region2.id,
               "id" => settlement1.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Рокитне",
               "mountain_group" => false,
               "type" => "1",
               "koatuu" => "11",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Білоцерківський",
               "region_id" => region1.id,
               "id" => settlement3.id,
               "area" => "Київська",
               "area_id" => area1.id,
               "name" => "Володарка",
               "mountain_group" => false,
               "type" => "3",
               "koatuu" => "13",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Білоцерківський",
               "area_id" => area1.id,
               "region_id" => region1.id,
               "id" => settlement4.id,
               "area" => "Київська",
               "name" => "Біла Церква",
               "mountain_group" => false,
               "type" => "4",
               "koatuu" => "14",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement5.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Миколаївка",
               "mountain_group" => false,
               "type" => "5",
               "koatuu" => "15",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Миколаївський",
               "region_id" => region3.id,
               "id" => settlement6.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Якесь село",
               "mountain_group" => false,
               "type" => "6",
               "koatuu" => "16",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             },
             %{
               "region" => "Комінтернівський",
               "region_id" => region4.id,
               "id" => settlement7.id,
               "area" => "Одеська",
               "area_id" => area2.id,
               "name" => "Комінтерне",
               "mountain_group" => false,
               "type" => "7",
               "koatuu" => "17",
               "parent_settlement" => nil,
               "parent_settlement_id" => nil
             }
           ]
           |> Enum.map(&Enum.member?(response, &1))
           |> Enum.all?()
  end

  test "show settlement", %{conn: conn} do
    area = insert(:area, name: "Одеська", koatuu: "1")
    region = insert(:region, area: area, name: "Білоцерківський")

    settlement =
      insert(:settlement,
        area: area,
        region: region,
        name: "Рокитне",
        type: "1",
        koatuu: "11",
        mountain_group: false,
        parent_settlement_id: nil
      )

    resp_entity =
      conn
      |> get(v2_settlement_path(conn, :show, settlement.id))
      |> json_response(200)
      |> Map.get("data")

    assert %{
             "area" => "Одеська",
             "area_id" => area.id,
             "id" => settlement.id,
             "koatuu" => "11",
             "mountain_group" => false,
             "name" => "Рокитне",
             "parent_settlement" => nil,
             "parent_settlement_id" => nil,
             "region" => "Білоцерківський",
             "region_id" => region.id,
             "type" => "1"
           } == resp_entity
  end

  test "not found settlement", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      conn
      |> get(v2_settlement_path(conn, :show, UUID.generate()))
      |> json_response(404)
    end
  end
end
