defmodule Uaddresses.Web.StreetControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Streets.Street

  @create_attrs %{
    district_id: "7488a646-e31f-11e4-aace-600308960662",
    postal_code: "some postal_code",
    region_id: "7488a646-e31f-11e4-aace-600308960662",
    settlement_id: "7488a646-e31f-11e4-aace-600308960662",
    street_name: "some street_name",
    numbers: ["some numbers"],
    street_type: "вулиця"
  }

  @update_attrs %{
    district_id: "7488a646-e31f-11e4-aace-600308960668",
    postal_code: "some updated postal_code",
    region_id: "7488a646-e31f-11e4-aace-600308960668",
    settlement_id: "7488a646-e31f-11e4-aace-600308960668",
    street_name: "some UPDATED street_name",
    numbers: ["some updated numbers"],
    street_type: "провулок"
  }

  @invalid_attrs %{
    district_id: nil,
    postal_code: nil,
    region_id: nil,
    settlement_id: nil,
    street_name: nil,
    numbers: nil,
    street_type: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
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
      "numbers" => ["some numbers"],
      "street_type" => "вулиця",
      "aliases" => ["some street_name"]}
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
      "street_name" => "some UPDATED street_name",
      "numbers" => ["some updated numbers"],
      "street_type" => "провулок",
      "aliases" => ["some street_name", "some UPDATED street_name"]}
  end

  test "does not update chosen street and renders errors when data is invalid", %{conn: conn} do
    street = fixture(:street)
    conn = put conn, street_path(conn, :update, street), street: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Київ"})
    r_2 = region(%{name: "Одеська"})
    d_1 = district(%{region_id: r_1.id, name: "Київ"})
    d_3 = district(%{region_id: r_2.id, name: "Миколаївський"})

    set_1 = settlement(%{region_id: r_1.id, district_id: d_1.id, name: "Київ"})

    set_2 = settlement(%{region_id: r_2.id, district_id: d_3.id, name: "Миколаївка"})

    # Одеська, Миколаївський, Миколаївка, вулиця Соломії Крушельницької 7 02140
    str_1 = street(%{region_id: r_2.id, district_id: d_3.id, settlement_id: set_2.id,
      street_name: "Соломії Крушельницької", street_type: "вулиця", numbers: ["7"], postal_code: "02140"})
    # Київ, Київ, Київ, бульвар Тараса Шевченка 31 02141
    str_2 = street(%{region_id: r_1.id, district_id: d_1.id, settlement_id: set_1.id,
      street_name: "Тараса Шевченка", street_type: "бульвар", numbers: ["13"], postal_code: "02141"})
    # Київ, Київ, Київ, вулиця Тараса Шевченка 13 02142
    str_3 = street(%{region_id: r_1.id, district_id: d_1.id, settlement_id: set_1.id,
      street_name: "Тараса Шевченка", street_type: "вулиця", numbers: ["13"], postal_code: "02142"})
    conn = put conn, street_path(conn, :update, str_1), street: %{street_name: "Нове ім'я"}

    conn = get conn, "/search/streets/"
    assert json_response(conn, 422)

    conn = get conn, "/search/streets/?region=Київ&settlement_name=Київ&numbers=13&street_name=Шевченка"

    assert json_response(conn, 200)["data"] == [
      %{"district" => "Київ", "id" => str_2.id, "postal_code" => "02141",
        "region" => "Київ", "settlement_name" => "Київ", "street_name" => "Тараса Шевченка",
        "numbers" => ["13"], "street_type" => "бульвар", "aliases" => ["Тараса Шевченка"]},
      %{"district" => "Київ", "id" => str_3.id, "postal_code" => "02142",
        "region" => "Київ", "settlement_name" => "Київ", "street_name" => "Тараса Шевченка",
        "numbers" => ["13"], "street_type" => "вулиця", "aliases" => ["Тараса Шевченка"]}
    ]

    conn = get conn,
      "/search/streets/?region=Київ&settlement_name=Київ&numbers=13&street_name=Шевченка&postal_code=02142"

    assert json_response(conn, 200)["data"] == [
      %{"district" => "Київ", "id" => str_3.id, "postal_code" => "02142",
        "region" => "Київ", "settlement_name" => "Київ", "street_name" => "Тараса Шевченка",
        "numbers" => ["13"], "street_type" => "вулиця", "aliases" => ["Тараса Шевченка"]}
    ]

    conn = get conn,
      "/search/streets/?region=Київ&settlement_name=Київ&numbers=13&street_name=Шевченка&street_type=вулиця"

    assert json_response(conn, 200)["data"] == [
      %{"district" => "Київ", "id" => str_3.id, "postal_code" => "02142",
        "region" => "Київ", "settlement_name" => "Київ", "street_name" => "Тараса Шевченка",
        "numbers" => ["13"], "street_type" => "вулиця", "aliases" => ["Тараса Шевченка"]}
    ]

    # settlement id has greater weight
    conn = get conn,
      "/search/streets/?region=Київ&settlement_name=Київ&numbers=7&street_name=круш&settlement_id=#{set_2.id}"
    assert json_response(conn, 200)["data"] == [
      %{"district" => "Миколаївський", "id" => str_1.id, "postal_code" => "02140",
        "region" => "Одеська", "settlement_name" => "Миколаївка", "street_name" => "Нове ім'я",
        "numbers" => ["7"], "street_type" => "вулиця", "aliases" => ["Соломії Крушельницької", "Нове ім'я"]}
    ]

    conn = get conn,
      "/search/streets/?region=Київ&settlement_name=Київ&numbers=7&street_name=ім'я&settlement_id=#{set_2.id}"
    assert json_response(conn, 200)["data"] == [
      %{"district" => "Миколаївський", "id" => str_1.id, "postal_code" => "02140",
        "region" => "Одеська", "settlement_name" => "Миколаївка", "street_name" => "Нове ім'я",
        "numbers" => ["7"], "street_type" => "вулиця", "aliases" => ["Соломії Крушельницької", "Нове ім'я"]}
    ]
  end
end
