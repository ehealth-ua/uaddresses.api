defmodule Uaddresses.Web.DistrictControllerTest do
  use Uaddresses.Web.ConnCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Districts.District

  @create_attrs %{name: "some name", region_id: "7488a646-e31f-11e4-aace-600308960662", koatuu: "1"}
  @update_attrs %{name: "some updated name", region_id: "7488a646-e31f-11e4-aace-600308960668", koatuu: "1"}
  @invalid_attrs %{name: nil, region_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
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
      "region" => "some region",
      "region_id" => region_id,
      "koatuu" => "1"
      }
  end

  test "does not create district and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, district_path(conn, :create), district: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen district and renders district when data is valid", %{conn: conn} do
    %District{id: id} = district = fixture(:district)
    region_id = district.region.id
    update_attrs = Map.put(@update_attrs, :region_id, region_id)
    conn = put conn, district_path(conn, :update, district), district: update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, district_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name",
      "region" => "some region",
      "region_id" => region_id,
      "koatuu" => "1"
      }
  end

  test "does not update chosen district and renders errors when data is invalid", %{conn: conn} do
    district = fixture(:district)
    conn = put conn, district_path(conn, :update, district), district: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "list of settlements by district", %{conn: conn} do
    district = district()
    first = settlement(%{name: "First settlement", region_id: district.region_id, district_id: district.id})
    second = settlement(%{name: "Second settlement", region_id: district.region_id, district_id: district.id})
    third = settlement(%{name: "Third settlement", region_id: district.region_id, district_id: district.id})

    conn = get conn, "/details/district/#{district.id}/settlements"
    assert json_response(conn, 200)["data"] == [
        %{"id" => first.id, "settlement_name" => "First settlement"},
        %{"id" => second.id, "settlement_name" => "Second settlement"},
        %{"id" => third.id, "settlement_name" => "Third settlement"}
      ]

    conn = get conn, "/details/district/#{district.id}/settlements?page_size=1&page=2"
    assert json_response(conn, 200)["data"] == [%{"id" => second.id, "settlement_name" => "Second settlement"}]

    get conn, "/details/district/#{district.id}/settlements?name=ond"
    assert json_response(conn, 200)["data"] == [%{"id" => second.id, "settlement_name" => "Second settlement"}]
  end

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Київ", koatuu: "1"})
    r_2 = region(%{name: "Одеська", koatuu: "1"})
    d_1 = district(%{region_id: r_1.id, name: "Дарницький", koatuu: "11"})
    d_2 = district(%{region_id: r_1.id, name: "Подільський", koatuu: "12"})
    d_3 = district(%{region_id: r_2.id, name: "Миколаївський", koatuu: "13"})
    d_4 = district(%{region_id: r_2.id, name: "Комінтернівський", koatuu: "14"})

    conn = get conn, "/districts/"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_1.id, "name" => "Дарницький", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "11"},
      %{"id" => d_2.id, "name" => "Подільський", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "12"},
      %{"id" => d_3.id, "name" => "Миколаївський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "13"},
      %{"id" => d_4.id, "name" => "Комінтернівський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "14"}
    ]

    conn = get conn, "/districts/?region=київ"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_1.id, "name" => "Дарницький", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "11"},
      %{"id" => d_2.id, "name" => "Подільський", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "12"}
    ]

    conn = get conn, "/districts/?region=київ&page_size=1"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_1.id, "name" => "Дарницький", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "11"}
    ]

    conn = get conn, "/districts/?region=київ&page_size=1&page=2"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_2.id, "name" => "Подільський", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "12"}
    ]

    conn = get conn, "/districts/?region=київ&region_id=#{r_2.id}"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_3.id, "name" => "Миколаївський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "13"},
      %{"id" => d_4.id, "name" => "Комінтернівський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "14"}
    ]

    conn = get conn, "/districts/?name=інтерні"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_4.id, "name" => "Комінтернівський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "14"}
    ]

    conn = get conn, "/districts/?koatuu=1"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_1.id, "name" => "Дарницький", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "11"},
      %{"id" => d_2.id, "name" => "Подільський", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "12"},
      %{"id" => d_3.id, "name" => "Миколаївський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "13"},
      %{"id" => d_4.id, "name" => "Комінтернівський", "region" => "Одеська", "region_id" => r_2.id, "koatuu" => "14"}
    ]

    conn = get conn, "/districts/?koatuu=2"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_2.id, "name" => "Подільський", "region" => "Київ", "region_id" => r_1.id, "koatuu" => "12"}
    ]
  end
end
