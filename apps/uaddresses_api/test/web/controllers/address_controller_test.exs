defmodule Uaddresses.Web.AddressControllerTest do
  use Uaddresses.Web.ConnCase

  alias Ecto.UUID
  alias Uaddresses.Repo
  import Ecto.Changeset

  describe "validate addresses" do
    test "success validate addresses", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      region = insert(:region, name: "ЖАШКІВСЬКИЙ", area: area)
      settlement = insert(:settlement, area: area, region: region)

      conn =
        post(conn, address_path(conn, :validate), %{
          "addresses" => [build(:address, settlement_id: settlement.id, settlement: settlement.name)]
        })

      assert json_response(conn, 200)
    end

    test "success validate address", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      region = insert(:region, name: "ЖАШКІВСЬКИЙ", area: area)
      settlement = insert(:settlement, area: area, region: region)

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => build(:address, settlement_id: settlement.id, settlement: settlement.name)
        })

      assert json_response(conn, 200)
    end

    test "invalid params", %{conn: conn} do
      conn = post(conn, address_path(conn, :validate), %{})
      assert resp = json_response(conn, 422)

      assert %{
               "error" => %{
                 "invalid" => [
                   %{"entry_type" => "request", "rules" => [%{"rule" => "json"}]}
                 ]
               }
             } = resp
    end

    test "invalid settlement_id", %{conn: conn} do
      id = UUID.generate()

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => build(:address, settlement_id: id)
        })

      assert resp = json_response(conn, 422)
      assert_error(resp, "$.settlement_id", "settlement with id = #{id} does not exist")
    end

    test "invalid settlement value", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      settlement = insert(:settlement, area: area)

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => build(:address, settlement_id: settlement.id, settlement: "invalid")
        })

      assert resp = json_response(conn, 422)
      assert_error(resp, "$.settlement", "invalid settlement value")
    end

    test "invalid region_id", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      settlement = insert(:settlement, area: area)
      area_id = UUID.generate()

      settlement =
        settlement
        |> cast(%{"area_id" => area_id}, ~w(area_id)a)
        |> Repo.update!()

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => build(:address, settlement_id: settlement.id, settlement: settlement.name)
        })

      assert resp = json_response(conn, 422)
      assert_error(resp, "$.settlement_id", "area with id = #{area_id} does not exist")
    end

    test "invalid region value", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      settlement = insert(:settlement, area: area)

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => build(:address, settlement_id: settlement.id, settlement: settlement.name, area: "invalid")
        })

      assert resp = json_response(conn, 422)
      assert_error(resp, "$.area", "invalid area value")
    end

    test "invalid district_id", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      settlement = insert(:settlement, area: area)
      region_id = UUID.generate()

      settlement =
        settlement
        |> cast(%{"region_id" => region_id}, ~w(region_id)a)
        |> Repo.update!()

      address = build(:address, settlement_id: settlement.id, settlement: settlement.name)

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => Map.merge(address, %{region: "some area"})
        })

      assert resp = json_response(conn, 422)
      assert_error(resp, "$.settlement_id", "region with id = #{region_id} does not exist")
    end

    test "invalid district value", %{conn: conn} do
      area = insert(:area, name: "Черкаська")
      region = insert(:region, name: "ЖАШКІВСЬКИЙ", area: area)
      settlement = insert(:settlement, area: area, region: region)

      address = build(:address, settlement_id: settlement.id, settlement: settlement.name)

      conn =
        post(conn, address_path(conn, :validate), %{
          "address" => Map.merge(address, %{region: "invalid"})
        })

      assert resp = json_response(conn, 422)
      assert_error(resp, "$.region", "invalid region value")
    end
  end

  defp assert_error(resp, path, message) do
    assert %{
             "invalid" => [
               %{
                 "entry" => ^path,
                 "entry_type" => "json_data_property",
                 "rules" => [
                   %{
                     "description" => ^message
                   }
                 ]
               }
             ]
           } = resp["error"]
  end
end
