defmodule Uaddresses.Web.StreetControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Streets.Street

  @create_attrs %{
    settlement_id: "7488a646-e31f-11e4-aace-600308960662",
    name: "some street_name",
    type: "вулиця"
  }

  @update_attrs %{
    settlement_id: "7488a646-e31f-11e4-aace-600308960668",
    name: "some UPDATED street_name",
    type: "провулок"
  }

  @invalid_attrs %{
    settlement_id: nil,
    name: nil,
    type: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates street and renders street when data is valid", %{conn: conn} do
    %{id: settlement_id} = settlement = settlement()
    district_id = settlement.district.id
    region_id = settlement.region.id
    create_attrs =
      Map.merge(@create_attrs, %{region_id: region_id, district_id: district_id, settlement_id: settlement_id})

    conn = post conn, street_path(conn, :create), street: create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, street_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "settlement_id" => settlement_id,
      "name" => "some street_name",
      "type" => "вулиця",
      "aliases" => ["some street_name"]}
  end

  test "does not create street and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, street_path(conn, :create), street: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen street and renders street when data is valid", %{conn: conn} do
    %Street{id: id} = street = Repo.preload(fixture(:street), :settlement)
    settlement_id = street.settlement.id
    update_attrs = Map.put(@update_attrs, :settlement_id, settlement_id)

    conn = put conn, street_path(conn, :update, street), street: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, street_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "settlement_id" => settlement_id,
      "name" => "some UPDATED street_name",
      "type" => "провулок",
      "aliases" => ["some street_name", "some UPDATED street_name"]
    }
  end

  test "does not update chosen street and renders errors when data is invalid", %{conn: conn} do
    street = fixture(:street)
    conn = put conn, street_path(conn, :update, street), street: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Київ", koatuu: "1"})
    r_2 = region(%{name: "Одеська", koatuu: "1"})
    d_1 = district(%{region_id: r_1.id, name: "Київ"})
    d_3 = district(%{region_id: r_2.id, name: "Миколаївський"})

    set_1 = settlement(%{region_id: r_1.id, district_id: d_1.id, name: "Київ"})

    set_2 = settlement(%{region_id: r_2.id, district_id: d_3.id, name: "Миколаївка"})

    str_1 = street(%{settlement_id: set_2.id, name: "Соломії Крушельницької", type: "вулиця"})
    str_2 = street(%{settlement_id: set_1.id, name: "Тараса Шевченка", type: "бульвар"})
    str_3 = street(%{settlement_id: set_1.id, name: "Тараса Шевченка", type: "вулиця"})
    str_4 = street(%{settlement_id: set_1.id, name: "Богдана Хмельницького", type: "вулиця"})

    conn = put conn, street_path(conn, :update, str_1), street: %{name: "Нове ім'я"}

    conn = get conn, "/streets/"
    assert json_response(conn, 422)

    conn = get conn, "/streets/?settlement_id=#{set_1.id}"

    assert json_response(conn, 200)["data"] == [
      %{"id" => str_2.id, "settlement_id" => set_1.id, "name" => "Тараса Шевченка", "type" => "бульвар",
        "aliases" => ["Тараса Шевченка"]},
      %{"id" => str_3.id, "settlement_id" => set_1.id, "name" => "Тараса Шевченка", "type" => "вулиця",
        "aliases" => ["Тараса Шевченка"]},
      %{"id" => str_4.id, "settlement_id" => set_1.id, "name" => "Богдана Хмельницького", "type" => "вулиця",
        "aliases" => ["Богдана Хмельницького"]}
    ]

    conn = get conn, "/streets/?settlement_id=#{set_1.id}&name=шевченка"

    assert json_response(conn, 200)["data"] == [
      %{"id" => str_2.id, "settlement_id" => set_1.id, "name" => "Тараса Шевченка", "type" => "бульвар",
        "aliases" => ["Тараса Шевченка"]},
      %{"id" => str_3.id, "settlement_id" => set_1.id, "name" => "Тараса Шевченка", "type" => "вулиця",
        "aliases" => ["Тараса Шевченка"]}
    ]

    conn = get conn, "/streets/?settlement_id=#{set_1.id}&name=шевченка&type=вулиця"

    assert json_response(conn, 200)["data"] == [
      %{"id" => str_3.id, "settlement_id" => set_1.id, "name" => "Тараса Шевченка", "type" => "вулиця",
        "aliases" => ["Тараса Шевченка"]}
    ]

    conn = get conn, "/streets/?settlement_id=#{set_2.id}&name=нове&type=вулиця"

    assert json_response(conn, 200)["data"] == [
      %{"id" => str_1.id, "settlement_id" => set_2.id, "name" => "Нове ім'я", "type" => "вулиця",
        "aliases" => ["Соломії Крушельницької", "Нове ім'я"]}
    ]
  end
end
