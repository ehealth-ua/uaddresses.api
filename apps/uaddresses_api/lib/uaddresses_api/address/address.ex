defmodule Uaddresses.Addresses.Address do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Uaddresses.Areas.Area
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement

  @fields_required ~w(
    type
    country
    area
    settlement
    settlement_type
    settlement_id
  )a

  @fields_optional ~w(
    street_type
    street
    apartment
    zip
    region
    building
  )a

  @primary_key false
  embedded_schema do
    field(:type, :string)
    field(:country, :string)
    field(:area, :string)
    field(:region, :string)
    field(:settlement, :string)
    field(:settlement_type, :string)
    field(:settlement_id, :string)
    field(:street_type, :string)
    field(:street, :string)
    field(:building, :string)
    field(:apartment, :string)
    field(:zip, :string)
  end

  def changeset(%__MODULE__{} = address, params) do
    address
    |> cast(params, @fields_required ++ @fields_optional)
    |> validate_required(@fields_required)
    |> validate_settlement()
  end

  defp validate_settlement(%Ecto.Changeset{changes: changes, valid?: true} = changeset) do
    with {:settlement_id, %Settlement{} = settlement} <-
           {:settlement_id, Settlements.get_settlement(changes.settlement_id)},
         {:settlement_value, true} <-
           {:settlement_value, String.upcase(settlement.name) == String.upcase(changes.settlement)},
         {:area_id, %Area{} = area, _} <- {:area_id, settlement.area, settlement.area_id},
         {:area_value, true} <- {:area_value, String.upcase(area.name) == String.upcase(changes.area)} do
      validate_region(settlement, changeset)
    else
      {:settlement_id, _} ->
        add_error(changeset, :settlement_id, "settlement with id = #{changes.settlement_id} does not exist")

      {:area_id, _, area_id} ->
        add_error(changeset, :settlement_id, "area with id = #{area_id} does not exist")

      {:settlement_value, _} ->
        add_error(changeset, :settlement, "invalid settlement value")

      {:area_value, _} ->
        add_error(changeset, :area, "invalid area value")
    end
  end

  defp validate_settlement(changeset), do: changeset

  defp validate_region(
         %Settlement{region_id: region_id} = settlement,
         %Ecto.Changeset{changes: %{region: region_name}, valid?: true} = changeset
       )
       when not is_nil(region_id) do
    with {:region_id, %Region{} = region} <- {:region_id, settlement.region},
         {:region_value, true} <- {:region_value, String.upcase(region.name) == String.upcase(region_name)} do
      changeset
    else
      {:region_id, _} ->
        add_error(changeset, :settlement_id, "region with id = #{region_id} does not exist")

      {:region_value, _} ->
        add_error(changeset, :region, "invalid region value")
    end
  end

  defp validate_region(_, changeset), do: changeset
end
