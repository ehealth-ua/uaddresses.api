defmodule Uaddresses.DistrictsTest do
  use Uaddresses.DataCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Districts
  alias Uaddresses.Districts.District

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil, region_id: nil}

  test "get_district! returns the district with given id" do
    district = fixture(:district)
    assert Districts.get_district!(district.id) == district
  end

  test "create_district/1 with valid data creates a district" do
    %{id: region_id} = region()

    assert {:ok, %District{} = district} =
      @create_attrs
      |> Map.put(:region_id, region_id)
      |> Districts.create_district()
    assert district.name == "some name"
    assert district.region_id == region_id
  end

  test "create_district/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Districts.create_district(@invalid_attrs)
  end

  test "update_district/2 with valid data updates the district" do
    district = fixture(:district)
    region_id = district.region.id
    updated_params = Map.put(@update_attrs, :region_id, region_id)
    assert {:ok, district} =Districts.update_district(district, updated_params)
    assert %District{} = district
    assert district.name == "some updated name"
    assert district.region_id == region_id
  end

  test "update_district/2 with invalid data returns error changeset" do
    district = fixture(:district)
    assert {:error, %Ecto.Changeset{}} = Districts.update_district(district, @invalid_attrs)
    assert district == Districts.get_district!(district.id)
  end

  test "delete_district/1 deletes the district" do
    district = fixture(:district)
    assert {:ok, %District{}} = Districts.delete_district(district)
    assert_raise Ecto.NoResultsError, fn -> Districts.get_district!(district.id) end
  end

  test "change_district/1 returns a district changeset" do
    district = fixture(:district)
    assert %Ecto.Changeset{} = Districts.change_district(district)
  end
end
