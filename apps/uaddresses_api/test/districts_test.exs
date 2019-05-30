defmodule Uaddresses.RegionsTest do
  use Uaddresses.DataCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil, area_id: nil}

  test "get_region! returns the district with given id" do
    region = fixture(:region)
    assert Regions.get_region!(region.id) == region
  end

  test "create_region/1 with valid data creates a district" do
    %{id: area_id} = area()

    assert {:ok, %Region{} = region} =
             @create_attrs
             |> Map.put(:area_id, area_id)
             |> Regions.create_region()

    assert region.name == "some name"
    assert region.area_id == area_id
  end

  test "create_region/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Regions.create_region(@invalid_attrs)
  end

  test "update_region/2 with valid data updates the region" do
    region = fixture(:region)
    area_id = region.area.id
    updated_params = Map.put(@update_attrs, :area_id, area_id)
    assert {:ok, region} = Regions.update_region(region, updated_params)
    assert %Region{} = region
    assert region.name == "some updated name"
    assert region.area_id == area_id
  end

  test "update_region/2 with invalid data returns error changeset" do
    region = fixture(:region)
    assert {:error, %Ecto.Changeset{}} = Regions.update_region(region, @invalid_attrs)
    assert region == Regions.get_region!(region.id)
  end

  test "delete_region/1 deletes the region" do
    region = fixture(:region)
    assert {:ok, %Region{}} = Regions.delete_region(region)
    assert_raise Ecto.NoResultsError, fn -> Regions.get_region!(region.id) end
  end

  test "change_region/1 returns a region changeset" do
    region = fixture(:region)
    assert %Ecto.Changeset{} = Regions.change_region(region)
  end
end
