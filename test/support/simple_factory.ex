defmodule Uaddresses.SimpleFactory do
  @moduledoc false
  alias Uaddresses.{Regions, Districts}

  def fixture(:district), do: district()
  def fixture(:region), do: region()

  def region() do
    {:ok, region} = Regions.create_region(%{name: "some region"})
    region
  end

  def district do
    %{id: region_id} = region()
    {:ok, district} = Districts.create_district(%{name: "some name", region_id: region_id})
    district
  end
end