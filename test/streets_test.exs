defmodule Uaddresses.StreetsTest do
  use Uaddresses.DataCase

  import Uaddresses.SimpleFactory

  alias Uaddresses.Streets
  alias Uaddresses.Streets.Street

  @create_attrs %{
    settlement_id: "7488a646-e31f-11e4-aace-600308960662",
    name: "some street_name",
    type: "вулиця"
  }

  @update_attrs %{
    settlement_id: "7488a646-e31f-11e4-aace-600308960668",
    name: "some updated street_name",
    type: "провулок"
  }

  @invalid_attrs %{
    settlement_id: nil,
    name: nil,
    type: nil
  }

  test "get_street! returns the street with given id" do
    street = fixture(:street)
    assert Streets.get_street!(street.id) == street
  end

  test "create_street/1 with valid data creates a street" do
    %{id: settlement_id} = settlement()

    assert {:ok, %Street{} = street} =
      @create_attrs
      |> Map.put(:settlement_id, settlement_id)
      |> Streets.create_street()

    assert street.settlement_id == settlement_id
    assert street.name == "some street_name"
    assert street.type == "вулиця"
  end

  test "create_street/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Streets.create_street(@invalid_attrs)
  end

  test "update_street/2 with valid data updates the street" do
    street = Repo.preload(fixture(:street), :settlement)
    settlement_id = street.settlement.id

    update_attrs = Map.put(@update_attrs, :settlement_id, settlement_id)

    assert {:ok, street} = Streets.update_street(street, update_attrs)
    assert %Street{} = street
    assert street.settlement_id == settlement_id
    assert street.name == "some updated street_name"
    assert street.type == "провулок"
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
