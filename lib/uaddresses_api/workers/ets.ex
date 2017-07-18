defmodule Uaddresses.Workers.Ets do
  @moduledoc """
  GenServer Worker. Balance Updater
  """
  use GenServer

  alias Uaddresses.Regions
  alias Uaddresses.Districts
  alias Uaddresses.Settlements
  alias Uaddresses.Streets

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(_) do
    # {region_id, region_name, koatuu}
    :ets.new(:regions, [:set, :public, :named_table, read_concurrency: true])
    Enum.each(Regions.list_regions(), fn(region) ->
      :ets.insert(:regions, {region.id, String.downcase(region.name), String.downcase(to_string(region.koatuu))})
    end)
    # {district_id, region_id, region_name, district_name, koatuu}
    :ets.new(:districts, [:set, :public, :named_table, read_concurrency: true])
    Enum.each(Districts.list_districts(), fn(district) ->
      :ets.insert(:districts,
        {district.id, district.region_id, String.downcase(district.region.name), String.downcase(district.name),
          String.downcase(to_string(district.koatuu))})
    end)
    # {settlement_id, region_name, district_name, settlement_name, type, mountain_group, koatuu}
    :ets.new(:settlements, [:set, :public, :named_table, read_concurrency: true])
    Enum.each(Settlements.list_settlements(), fn(settlement) ->
      :ets.insert(:settlements,
        {
          settlement.id,
          String.downcase(settlement.region.name),
          get_district_name(settlement.district),
          String.downcase(settlement.name),
          String.downcase(to_string(settlement.type)),
          String.downcase(to_string(settlement.mountain_group)),
          String.downcase(to_string(settlement.koatuu))
        }
      )
    end)
    # {street_id, settlement_id, street_name, type}
    :ets.new(:streets, [:set, :public, :named_table, :duplicate_bag, read_concurrency: true])
    Enum.each(Streets.list_streets(), fn(street) ->
      :ets.insert(:streets, {street.id, street.settlement_id, String.downcase(street.name), street.type})
    end)
    {:ok, []}
  end

  defp get_district_name(nil), do: nil
  defp get_district_name(district), do: String.downcase(district.name)
end
