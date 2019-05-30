defmodule Uaddresses.SimpleFactory do
  @moduledoc false
  alias Uaddresses.{Areas, Regions, Settlements, Streets}

  def fixture(:region), do: region()
  def fixture(:area), do: area()
  def fixture(:settlement), do: settlement()
  def fixture(:street), do: street()

  def area do
    area(%{name: "some area", koatuu: "1"})
  end

  def area(params) do
    {:ok, area} = Areas.create_area(params)
    area
  end

  def region do
    %{id: area_id} = area()
    region(%{name: "some name", area_id: area_id})
  end

  def region(params) do
    {:ok, region} = Regions.create_region(params)
    region
  end

  def settlement do
    %{id: area_id} = area()
    %{id: region_id} = region(%{area_id: area_id, name: "some name"})
    settlement(%{name: "some name", area_id: area_id, region_id: region_id, mountain_group: false})
  end

  def settlement(params) do
    {:ok, settlement} = Settlements.create_settlement(params)
    settlement
  end

  def street do
    %{id: settlement_id} = settlement()

    street(%{
      settlement_id: settlement_id,
      name: "some street_name",
      type: "вулиця"
    })
  end

  def street(params) do
    {:ok, street} = Streets.create_street(params)
    street
  end
end
