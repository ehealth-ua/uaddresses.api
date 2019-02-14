defmodule Uaddresses.RpcTest do
  @moduledoc false

  use Uaddresses.DataCase, async: true

  alias Ecto.UUID
  alias Uaddresses.Rpc

  describe "validate/1" do
    test "invalid params" do
      assert :error == Rpc.validate(%{})
    end

    test "validation failed" do
      settlement_id = UUID.generate()
      error_message = "settlement with id = #{settlement_id} does not exist"

      assert {:error,
              %{
                invalid: [
                  %{
                    entry: "$.addresses[0].settlement_id",
                    entry_type: "query_parameter",
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

    test "validation sucess" do
      region = insert(:region, name: "Черкаська")
      district = insert(:district, name: "ЖАШКІВСЬКИЙ", region: region)
      settlement = insert(:settlement, region: region, district: district)

      assert :ok =
               Rpc.validate([
                 %{
                   "type" => "RESIDENCE",
                   "country" => "UA",
                   "area" => region.name,
                   "region" => district.name,
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
      region = insert(:region, name: "ГАСПРА")
      insert(:region, name: "ГАСПРА_2")
      insert(:region, name: "ГАСПРА_3")
      insert_list(4, :region)

      filter = [{:name, :like, "ГАСПРА"}]
      {:ok, resp_entities} = Rpc.search_regions(filter, [desc: :koatuu], {0, 10})

      assert 3 == length(resp_entities)
      assert region.id in Enum.map(resp_entities, & &1.id)
    end

    test "success search_districts/3" do
      district = insert(:district, name: "ГАСПРА")
      insert(:district, name: "ГАСПРА_2")
      insert_list(4, :district)

      filter = [{:name, :like, "ГАСПРА"}]
      {:ok, resp_entities} = Rpc.search_districts(filter, [], {0, 10})

      assert 2 == length(resp_entities)
      assert district.id in Enum.map(resp_entities, & &1.id)
    end

    test "search_settlements empty response" do
      assert {:ok, []} == Rpc.search_settlements([{:id, :in, [UUID.generate()]}])
    end
  end
end
