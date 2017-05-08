defmodule Uaddresses.SimpleFactory do
  @moduledoc false
  alias Uaddresses.{Regions, Districts, Settlements, Streets}

  def fixture(:district), do: district()
  def fixture(:region), do: region()
  def fixture(:settlement), do: settlement()
  def fixture(:street), do: street()

  def region() do
    {:ok, region} = Regions.create_region(%{name: "some region"})
    region
  end

  def district do
    %{id: region_id} = region()
    {:ok, district} = Districts.create_district(%{name: "some name", region_id: region_id})
    district
  end

  def settlement do
    %{id: region_id} = region()
    %{id: district_id} = district()

    {:ok, settlement} =
      Settlements.create_settlement(%{name: "some name", region_id: region_id, district_id: district_id})
    settlement
  end

  def street do
    %{id: region_id} = region()
    %{id: district_id} = district()
    %{id: settlement_id} = settlement()


    {:ok, street} =
      Streets.create_street(%{
        district_id: district_id,
        region_id: region_id,
        settlement_id: settlement_id,
        street_name: "some street_name",
        street_number: "some street_number",
        street_type: "some street_type", postal_code: "some postal_code"}
        )
     street
  end

end