defmodule Uaddresses.SimpleFactory do
  @moduledoc false
  alias Uaddresses.{Regions, Districts, Settlements, Streets}

  def fixture(:district), do: district()
  def fixture(:region), do: region()
  def fixture(:settlement), do: settlement()
  def fixture(:street), do: street()

  def region do
    region(%{name: "some region"})
  end

  def region(params) do
    {:ok, region} = Regions.create_region(params)
    region
  end

  def district do
    %{id: region_id} = region()
    district(%{name: "some name", region_id: region_id})
  end

  def district(params) do
    {:ok, district} = Districts.create_district(params)
    district
  end

  def settlement do
    %{id: region_id} = region()
    %{id: district_id} = district()
    settlement(%{name: "some name", region_id: region_id, district_id: district_id, mountain_group: false})
  end

  def settlement(params) do
    params = Map.put_new(params, :mountain_group, false)
    {:ok, settlement} = Settlements.create_settlement(params)
    settlement
  end

  def street do
    %{id: region_id} = region()
    %{id: district_id} = district()
    %{id: settlement_id} = settlement()

    street(%{
      district_id: district_id,
      region_id: region_id,
      settlement_id: settlement_id,
      street_name: "some street_name",
      street_number: "some street_number",
      street_type: "вулиця", postal_code: "some postal_code"
      }
    )
  end

  def street(params) do
    {:ok, street} = Streets.create_street(params)
    street
  end
end
