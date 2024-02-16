defmodule Uaddresses.SettlementsTest do
  use Uaddresses.DataCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement

  @create_attrs %{name: "some name", mountain_group: false}
  @update_attrs %{name: "some updated name", mountain_group: true}
  @invalid_attrs %{district_id: nil, name: nil, area_id: nil}

  test "get_settlement! returns the settlement with given id" do
    settlement = fixture(:settlement)
    assert Settlements.get_settlement!(settlement.id) == settlement
  end

  test "create_settlement/1 with valid data creates a settlement" do
    %{id: region_id} = region = region()
    area_id = region.area.id

    assert {:ok, %Settlement{} = settlement} =
             @create_attrs
             |> Map.merge(%{area_id: area_id, region_id: region_id})
             |> Settlements.create_settlement()

    assert settlement.region_id == region_id
    assert settlement.name == "some name"
    assert settlement.area_id == area_id
  end

  test "create_settlement/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Settlements.create_settlement(@invalid_attrs)
  end

  test "update_settlement/2 with valid data updates the settlement" do
    settlement = fixture(:settlement)
    area_id = settlement.area.id
    district_id = settlement.region.id
    update_attrs = Map.merge(@update_attrs, %{area_id: area_id, district_id: district_id})
    assert {:ok, settlement} = Settlements.update_settlement(settlement, update_attrs)
    assert %Settlement{} = settlement
    assert settlement.region_id == district_id
    assert settlement.name == "some updated name"
    assert settlement.area_id == area_id
  end

  test "update_settlement/2 without district_id" do
    settlement = fixture(:settlement)
    area_id = settlement.area.id
    update_attrs = Map.merge(@update_attrs, %{area_id: area_id})
    assert {:ok, settlement} = Settlements.update_settlement(settlement, update_attrs)
    assert %Settlement{} = settlement
    assert settlement.name == "some updated name"
    assert settlement.area_id == area_id
  end

  test "update_settlement/2 with empty district_id" do
    settlement = fixture(:settlement)
    area_id = settlement.area.id
    update_attrs = Map.merge(@update_attrs, %{area_id: area_id, district_id: nil})
    assert {:ok, settlement} = Settlements.update_settlement(settlement, update_attrs)
    assert %Settlement{} = settlement
    assert settlement.name == "some updated name"
    assert settlement.area_id == area_id
  end

  test "update_settlement/2 with invalid data returns error changeset" do
    settlement = fixture(:settlement)
    assert {:error, %Ecto.Changeset{}} = Settlements.update_settlement(settlement, @invalid_attrs)
    assert settlement == Settlements.get_settlement!(settlement.id)
  end

  test "delete_settlement/1 deletes the settlement" do
    settlement = fixture(:settlement)
    assert {:ok, %Settlement{}} = Settlements.delete_settlement(settlement)
    assert_raise Ecto.NoResultsError, fn -> Settlements.get_settlement!(settlement.id) end
  end
end
