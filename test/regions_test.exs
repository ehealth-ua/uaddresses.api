defmodule Uaddresses.RegionsTest do
  use Uaddresses.DataCase

  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region

  @create_attrs %{name: "some region"}
  @update_attrs %{name: "some updated region"}
  @invalid_attrs %{name: nil}

  def fixture(:name, attrs \\ @create_attrs) do
    {:ok, region} = Regions.create_region(attrs)
    region
  end

  test "list_regions/1 returns all regions" do
    region = fixture(:name)
    assert Regions.list_regions() == [region]
  end

  test "get_region! returns the region with given id" do
    region = fixture(:name)
    assert Regions.get_region!(region.id) == region
  end

  test "create_region/1 with valid data creates a region" do
    assert {:ok, %Region{} = region} = Regions.create_region(@create_attrs)
    assert region.name == "some region"
  end

  test "create_region/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Regions.create_region(@invalid_attrs)
  end

  test "update_region/2 with valid data updates the region" do
    region = fixture(:name)
    assert {:ok, region} = Regions.update_region(region, @update_attrs)
    assert %Region{} = region
    assert region.name == "some updated region"
  end

  test "update_region/2 with invalid data returns error changeset" do
    region = fixture(:name)
    assert {:error, %Ecto.Changeset{}} = Regions.update_region(region, @invalid_attrs)
    assert region == Regions.get_region!(region.id)
  end

  test "delete_region/1 deletes the region" do
    region = fixture(:name)
    assert {:ok, %Region{}} = Regions.delete_region(region)
    assert_raise Ecto.NoResultsError, fn -> Regions.get_region!(region.id) end
  end

  test "change_region/1 returns a region changeset" do
    region = fixture(:name)
    assert %Ecto.Changeset{} = Regions.change_region(region)
  end
end
