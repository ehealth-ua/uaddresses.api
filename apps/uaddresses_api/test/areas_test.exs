defmodule Uaddresses.AreasTest do
  use Uaddresses.DataCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Areas
  alias Uaddresses.Areas.Area

  @create_attrs %{name: "some area", koatuu: "1"}
  @update_attrs %{name: "some updated area", koatuu: "2"}
  @invalid_attrs %{name: nil}

  test "get_area! returns the region with given id" do
    area = fixture(:area)
    assert Areas.get_area!(area.id) == area
  end

  test "create_area/1 with valid data creates a region" do
    assert {:ok, %Area{} = area} = Areas.create_area(@create_attrs)
    assert area.name == "some area"
  end

  test "create_area/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Areas.create_area(@invalid_attrs)
  end

  test "update_area/2 with valid data updates the region" do
    area = fixture(:area)
    assert {:ok, area} = Areas.update_area(area, @update_attrs)
    assert %Area{} = area
    assert area.name == "some updated area"
  end

  test "update_area/2 with invalid data returns error changeset" do
    area = fixture(:area)
    assert {:error, %Ecto.Changeset{}} = Areas.update_area(area, @invalid_attrs)
    assert area == Areas.get_area!(area.id)
  end

  test "delete_area/1 deletes the region" do
    area = fixture(:area)
    assert {:ok, %Area{}} = Areas.delete_area(area)
    assert_raise Ecto.NoResultsError, fn -> Areas.get_area!(area.id) end
  end
end
