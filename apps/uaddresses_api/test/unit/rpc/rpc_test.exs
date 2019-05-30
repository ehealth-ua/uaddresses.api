defmodule Uaddresses.RpcTest do
  @moduledoc false

  use Uaddresses.DataCase, async: true

  alias Ecto.UUID
  alias Uaddresses.Rpc

  describe "validate/1" do
    test "invalid params" do
      assert :error == Rpc.validate(nil)
    end

    test "validation list failed" do
      settlement_id = UUID.generate()
      error_message = "settlement with id = #{settlement_id} does not exist"

      assert {:error,
              %{
                invalid: [
                  %{
                    entry: "$.addresses[0].settlement_id",
                    entry_type: "json_data_property",
                    rules: [
                      %{
                        description: ^error_message,
                        params: [],
                        rule: nil
                      }
                    ]
                  }
                ]
              }} =
               Rpc.validate([
                 %{
                   "type" => "RESIDENCE",
                   "country" => "UA",
                   "area" => "Житомирська",
                   "region" => "Бердичівський",
                   "settlement" => "Київ",
                   "settlement_type" => "CITY",
                   "settlement_id" => settlement_id,
                   "street_type" => "STREET",
                   "street" => "вул. Ніжинська",
                   "building" => "15",
                   "apartment" => "23",
                   "zip" => "02090"
                 }
               ])
    end

    test "validation map failed" do
      settlement_id = UUID.generate()
      error_message = "settlement with id = #{settlement_id} does not exist"

      assert {:error,
              %{
                invalid: [
                  %{
                    entry: "$.settlement_id",
                    entry_type: "json_data_property",
                    rules: [
                      %{
                        description: ^error_message,
                        params: [],
                        rule: nil
                      }
                    ]
                  }
                ]
              }} =
               Rpc.validate(%{
                 "type" => "RESIDENCE",
                 "country" => "UA",
                 "area" => "Житомирська",
                 "region" => "Бердичівський",
                 "settlement" => "Київ",
                 "settlement_type" => "CITY",
                 "settlement_id" => settlement_id,
                 "street_type" => "STREET",
                 "street" => "вул. Ніжинська",
                 "building" => "15",
                 "apartment" => "23",
                 "zip" => "02090"
               })
    end

    test "validation list success" do
      area = insert(:area, name: "Черкаська")
      region = insert(:region, name: "ЖАШКІВСЬКИЙ", area: area)
      settlement = insert(:settlement, area: area, region: region)

      assert :ok =
               Rpc.validate([
                 %{
                   "type" => "RESIDENCE",
                   "country" => "UA",
                   "area" => area.name,
                   "region" => region.name,
                   "settlement" => settlement.name,
                   "settlement_type" => "CITY",
                   "settlement_id" => settlement.id,
                   "street_type" => "STREET",
                   "street" => "вул. Ніжинська",
                   "building" => "15",
                   "apartment" => "23",
                   "zip" => "02090"
                 }
               ])
    end

    test "validation map success" do
      area = insert(:area, name: "Черкаська")
      region = insert(:region, name: "ЖАШКІВСЬКИЙ", area: area)
      settlement = insert(:settlement, area: area, region: region)

      assert :ok =
               Rpc.validate(%{
                 "type" => "RESIDENCE",
                 "country" => "UA",
                 "area" => area.name,
                 "region" => region.name,
                 "settlement" => settlement.name,
                 "settlement_type" => "CITY",
                 "settlement_id" => settlement.id,
                 "street_type" => "STREET",
                 "street" => "вул. Ніжинська",
                 "building" => "15",
                 "apartment" => "23",
                 "zip" => "02090"
               })
    end
  end

  describe "get settlement by id" do
    test "settlement not found" do
      refute Rpc.settlement_by_id(UUID.generate())
    end

    test "success get settlement by id" do
      settlement = insert(:settlement)
      id = settlement.id

      assert {:ok, %{id: ^id}} = Rpc.settlement_by_id(id)
    end
  end

  describe "search entities" do
    test "success search_settlements/3" do
      settlement = insert(:settlement, name: "ГАСПРА", mountain_group: false)
      insert_list(2, :settlement, name: "ГАСПРА_2", mountain_group: true)
      insert_list(4, :settlement)

      filter = [{:name, :like, "ГАСПРА"}]
      {:ok, resp_entities} = Rpc.search_settlements(filter, [asc: :mountain_group], {0, 2})

      assert 2 == length(resp_entities)
      assert settlement.id == hd(resp_entities).id
    end

    test "success search_regions/3" do
      area = insert(:area, name: "ГАСПРА")
      insert(:area, name: "ГАСПРА_2")
      insert(:area, name: "ГАСПРА_3")
      insert_list(4, :area)

      filter = [{:name, :like, "ГАСПРА"}]
      {:ok, resp_entities} = Rpc.search_regions(filter, [desc: :koatuu], {0, 10})

      assert 3 == length(resp_entities)
      assert area.id in Enum.map(resp_entities, & &1.id)
    end

    test "success search_districts/3" do
      region = insert(:region, name: "ГАСПРА")
      insert(:region, name: "ГАСПРА_2")
      insert_list(4, :region)

      filter = [{:name, :like, "ГАСПРА"}]
      {:ok, resp_entities} = Rpc.search_districts(filter, [], {0, 10})

      assert 2 == length(resp_entities)
      assert region.id in Enum.map(resp_entities, & &1.id)
    end

    test "search_settlements empty response" do
      assert {:ok, []} == Rpc.search_settlements([{:id, :in, [UUID.generate()]}])
    end

    test "search_districts successfully compatible with v1 naming" do
      # areas were regions
      # regions were districts

      area = insert(:area)
      insert_list(2, :region, area: area)
      insert_list(4, :region)

      filter = [{:region_id, :equal, area.id}]

      assert {:ok, districts} = Rpc.search_districts(filter)
      assert 2 == length(districts)
    end

    test "search_settlements successfully compatible with v1 naming" do
      area = insert(:area)
      region = insert(:region, area: area)
      insert_list(2, :settlement, area: area, region: region)
      insert_list(4, :settlement)

      filter = [{:region_id, :equal, area.id}, {:district_id, :equal, region.id}]

      assert {:ok, settlements} = Rpc.search_settlements(filter)
      assert 2 == length(settlements)
    end
  end
end
