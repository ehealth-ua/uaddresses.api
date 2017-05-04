defmodule Uaddresses.SimpleFactory do
  @moduledoc false
  alias Uaddresses.{Regions, Districts, Settlements}

  def fixture(:district), do: district()
  def fixture(:region), do: region()
  def fixture(:settlement), do: settlement()

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

end