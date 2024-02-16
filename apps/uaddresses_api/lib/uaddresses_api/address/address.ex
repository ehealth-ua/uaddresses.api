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
    with {:ok, settlement} <- get_settlement(changes.settlement_id, changeset),
         :ok <- compare_settlement_names(changes.settlement, settlement, changeset),
         :ok <- check_area(settlement.area, settlement.area_id, changeset),
         :ok <- compare_area_names(changes.area, settlement.area, changeset) do
      validate_region(settlement, changeset)
    end
  end

  defp validate_settlement(changeset), do: changeset

  defp get_settlement(settlement_id, changeset) do
    case Settlements.get_settlement(settlement_id) do
      %Settlement{} = settlement ->
        {:ok, settlement}

      _ ->
        add_error(changeset, :settlement_id, "settlement with id = #{settlement_id} does not exist")
    end
  end

  defp compare_settlement_names(settlement_name, settlement, changeset) do
    if String.upcase(settlement_name) == String.upcase(settlement.name) do
      :ok
    else
      add_error(changeset, :settlement, "invalid settlement value")
    end
  end

  defp check_area(%Area{}, _, _), do: :ok

  defp check_area(_, area_id, changeset),
    do: add_error(changeset, :settlement_id, "area with id = #{area_id} does not exist")

  defp compare_area_names(area_name, area, changeset) do
    if String.upcase(area_name) == String.upcase(area.name) do
      :ok
    else
      add_error(changeset, :area, "invalid area value")
    end
  end

  defp validate_region(
         %Settlement{region_id: region_id} = settlement,
         %Ecto.Changeset{changes: %{region: region_name}, valid?: true} = changeset
       )
       when not is_nil(region_id) do
    with {:ok, region} <- get_region_from_settlement(settlement, changeset),
         :ok <- compare_region_names(region_name, region, changeset) do
      changeset
    end
  end

  defp validate_region(_, changeset), do: changeset

  defp get_region_from_settlement(settlement, changeset) do
    case settlement.region do
      %Region{} = region -> {:ok, region}
      _ -> add_error(changeset, :settlement_id, "region with id = #{settlement.region_id} does not exist")
    end
  end

  defp compare_region_names(region_name, region, changeset) do
    if String.upcase(region.name) == String.upcase(region_name) do
      :ok
    else
      add_error(changeset, :region, "invalid region value")
    end
  end
end
