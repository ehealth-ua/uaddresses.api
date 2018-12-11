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
               Rpc.validate(%{
                 "addresses" => [
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
                 ]
               })
    end

    test "validation sucess" do
      region = insert(:region, name: "Черкаська")
      district = insert(:district, name: "ЖАШКІВСЬКИЙ", region: region)
      settlement = insert(:settlement, region: region, district: district)

      assert :ok =
               Rpc.validate(%{
                 "addresses" => [
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
                 ]
               })
    end
  end
end
