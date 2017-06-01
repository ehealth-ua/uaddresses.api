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

    conn = get conn, "/details/district/#{district.id}/settlements?limit=1&starting_after=#{first.id}"
    assert json_response(conn, 200)["data"] == [%{"id" => second.id, "settlement_name" => "Second settlement"}]

    get conn, "/details/district/#{district.id}/settlements?name=ond"
    assert json_response(conn, 200)["data"] == [%{"id" => second.id, "settlement_name" => "Second settlement"}]
  end

  test "search", %{conn: conn} do
    r_1 = region(%{name: "Київ"})
    r_2 = region(%{name: "Одеська"})
    d_1 = district(%{region_id: r_1.id, name: "Дарницький"})
    d_2 = district(%{region_id: r_1.id, name: "Подільський"})
    d_3 = district(%{region_id: r_2.id, name: "Миколаївський"})
    d_4 = district(%{region_id: r_2.id, name: "Комінтернівський"})

    conn = get conn, "/search/districts/"
    assert json_response(conn, 422)

    conn = get conn, "/search/districts/?region=Київ"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_1.id, "district" => "Дарницький", "region" => "Київ"},
      %{"id" => d_2.id, "district" => "Подільський", "region" => "Київ"}
    ]

    conn = get conn, "/search/districts/?region=Київ&limit=1"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_1.id, "district" => "Дарницький", "region" => "Київ"}
    ]

    conn = get conn, "/search/districts/?region=Київ&limit=1&starting_after=#{d_1.id}"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_2.id, "district" => "Подільський", "region" => "Київ"}
    ]

    conn = get conn, "/search/districts/?region=Київ&region_id=#{r_2.id}"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_3.id, "district" => "Миколаївський", "region" => "Одеська"},
      %{"id" => d_4.id, "district" => "Комінтернівський", "region" => "Одеська"}
    ]

    conn = get conn, "/search/districts/?region=Одеська&district=інтерні"
    assert json_response(conn, 200)["data"] == [
      %{"id" => d_4.id, "district" => "Комінтернівський", "region" => "Одеська"}
    ]
  end
end
