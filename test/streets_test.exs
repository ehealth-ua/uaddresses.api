defmodule Uaddresses.StreetsTest do
  use Uaddresses.DataCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Streets
  alias Uaddresses.Streets.Street

  @create_attrs %{
    district_id: "7488a646-e31f-11e4-aace-600308960662",
    region_id: "7488a646-e31f-11e4-aace-600308960662",
    settlement_id: "7488a646-e31f-11e4-aace-600308960662",
    street_name: "some street_name",
    numbers: ["some numbers"],
    street_type: "вулиця",
    postal_code: "some postal_code"
  }

  @update_attrs %{
    district_id: "7488a646-e31f-11e4-aace-600308960668",
    region_id: "7488a646-e31f-11e4-aace-600308960668",
    settlement_id: "7488a646-e31f-11e4-aace-600308960668",
    street_name: "some updated street_name",
    numbers: ["some updated numbers"],
    street_type: "провулок",
    postal_code: "some updated postal_code"
  }

  @invalid_attrs %{
    district_id: nil,
    region_id: nil,
    settlement_id: nil,
    street_name: nil,
    numbers: nil,
    street_type: nil
  }

  test "list_streets/1 returns all streets" do
    street = fixture(:street)
    assert Streets.list_streets() == [street]
  end

  test "get_street! returns the street with given id" do
    street = fixture(:street)
    assert Streets.get_street!(street.id) == street
  end

  test "create_street/1 with valid data creates a street" do
    %{id: region_id} = region()
    %{id: district_id} = district()
    %{id: settlement_id} = settlement()

    assert {:ok, %Street{} = street} =
      @create_attrs
      |> Map.merge(%{region_id: region_id, district_id: district_id, settlement_id: settlement_id})
      |> Streets.create_street()

    assert street.district_id == district_id
    assert street.region_id == region_id
    assert street.settlement_id == settlement_id
    assert street.street_name == "some street_name"
    assert street.numbers == ["some numbers"]
    assert street.street_type == "вулиця"
    assert street.postal_code == "some postal_code"
  end

  test "create_street/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Streets.create_street(@invalid_attrs)
  end

  test "update_street/2 with valid data updates the street" do
    street = fixture(:street)
    %{id: region_id} = region()
    %{id: district_id} = district()
    %{id: settlement_id} = settlement()

    update_attrs =
      Map.merge(@update_attrs, %{region_id: region_id, district_id: district_id, settlement_id: settlement_id})

    assert {:ok, street} = Streets.update_street(street, update_attrs)
    assert %Street{} = street
    assert street.district_id == district_id
    assert street.region_id == region_id
    assert street.settlement_id == settlement_id
    assert street.street_name == "some updated street_name"
    assert street.numbers == ["some updated numbers"]
    assert street.street_type == "провулок"
    assert street.postal_code == "some updated postal_code"
  end

  test "update_street/2 with invalid data returns error changeset" do
    street = fixture(:street)
    assert {:error, %Ecto.Changeset{}} = Streets.update_street(street, @invalid_attrs)
    assert street == Streets.get_street!(street.id)
  end

  test "delete_street/1 deletes the street" do
    street = fixture(:street)
    assert {:ok, %Street{}} = Streets.delete_street(street)
    assert_raise Ecto.NoResultsError, fn -> Streets.get_street!(street.id) end
  end

  test "change_street/1 returns a street changeset" do
    street = fixture(:street)
    assert %Ecto.Changeset{} = Streets.change_street(street)
  end
end
