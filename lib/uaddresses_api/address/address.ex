defmodule Uaddresses.Addresses.Address do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Uaddresses.Districts.District
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement

  @primary_key false

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
         {:region_id, %Region{} = region, _} <- {:region_id, settlement.region, settlement.region_id},
         {:region_value, true} <- {:region_value, String.upcase(region.name) == String.upcase(changes.area)} do
      validate_district(settlement, changeset)
    else
      {:settlement_id, _} ->
        add_error(changeset, :settlement_id, "settlement with id = #{changes.settlement_id} does not exist")

      {:region_id, _, region_id} ->
        add_error(changeset, :settlement_id, "region with id = #{region_id} does not exist")

      {:settlement_value, _} ->
        add_error(changeset, :settlement, "invalid settlement value")

      {:region_value, _} ->
        add_error(changeset, :area, "invalid area value")
    end
  end

  defp validate_settlement(changeset), do: changeset

  defp validate_district(
         %Settlement{district_id: district_id} = settlement,
         %Ecto.Changeset{changes: %{region: region}, valid?: true} = changeset
       )
       when not is_nil(district_id) do
    with {:district_id, %District{} = district} <- {:district_id, settlement.district},
         {:district_value, true} <- {:district_value, String.upcase(district.name) == String.upcase(region)} do
      changeset
    else
      {:district_id, _} ->
        add_error(changeset, :settlement_id, "district with id = #{district_id} does not exist")

      {:district_value, _} ->
        add_error(changeset, :region, "invalid region value")
    end
  end

  defp validate_district(_, changeset), do: changeset
end
