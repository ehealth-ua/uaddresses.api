defmodule Uaddresses.Settlements do
  @moduledoc """
  The boundary for the Settlements system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Search

  alias Uaddresses.Repo
  alias Uaddresses.Districts
  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region
  alias Uaddresses.Districts.District
  alias Uaddresses.Settlements.Settlement
  alias Uaddresses.Settlements.Search

  @doc """
  Returns the list of settlements.

  ## Examples

      iex> list_settlements()
      [%Settlement{}, ...]

  """
  def list_settlements(params) do
    params
    |> search_changeset()
    |> search(params, Settlement)
  end

  @doc """
  Gets a single settlement.

  Raises `Ecto.NoResultsError` if the Settlement does not exist.

  ## Examples

      iex> get_settlement!(123)
      %Settlement{}

      iex> get_settlement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_settlement!(id) do
    Settlement
    |> preload([:region, :district, :parent_settlement])
    |> Repo.get!(id)
  end

  def get_settlement(nil), do: nil
  def get_settlement(id) do
    Settlement
    |> preload([:region, :district, :parent_settlement])
    |> Repo.get(id)
  end

  @doc """
  Creates a settlement.

  ## Examples

      iex> create_settlement(%{field: value})
      {:ok, %Settlement{}}

      iex> create_settlement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_settlement(attrs \\ %{}) do
    %Settlement{}
    |> settlement_changeset(attrs)
    |> Repo.insert()
    |> preload_embed()
  end

  @doc """
  Updates a settlement.

  ## Examples

      iex> update_settlement(settlement, %{field: new_value})
      {:ok, %Settlement{}}

      iex> update_settlement(settlement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_settlement(%Settlement{} = settlement, attrs) do
    settlement
    |> settlement_changeset(attrs)
    |> Repo.update()
    |> preload_embed()
  end

  defp preload_embed({:ok, settlement}), do: {:ok, Repo.preload(settlement, [:region, :district, :parent_settlement])}
  defp preload_embed({:error, reason}), do: {:error, reason}

  @doc """
  Deletes a Settlement.

  ## Examples

      iex> delete_settlement(settlement)
      {:ok, %Settlement{}}

      iex> delete_settlement(settlement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_settlement(%Settlement{} = settlement) do
    Repo.delete(settlement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking settlement changes.

  ## Examples

      iex> change_settlement(settlement)
      %Ecto.Changeset{source: %Settlement{}}

  """
  def change_settlement(%Settlement{} = settlement) do
    settlement_changeset(settlement, %{})
  end

  defp settlement_changeset(%Settlement{} = settlement, attrs) do
    settlement
    |> cast(attrs, [:district_id, :region_id, :name, :mountain_group, :type, :koatuu, :parent_settlement_id])
    |> validate_required([:region_id, :name])
    |> validate_region_exists(:region_id)
    |> validate_district_exists(:district_id)
  end

  defp validate_region_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> Regions.get_region()
    |> result_region_exists_validation(changeset)
  end

  defp result_region_exists_validation(nil, changeset) do
    add_error(changeset, :region_id, "Selected region doesn't exists'")
  end
  defp result_region_exists_validation(%Region{}, changeset), do: changeset

  defp validate_district_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> case do
         nil -> changeset
         field -> field |> Districts.get_district() |> result_district_exists_validation(changeset)
       end
  end

  defp result_district_exists_validation(nil, changeset) do
    add_error(changeset, :district_id, "Selected district doesn't exists'")
  end
  defp result_district_exists_validation(%District{}, changeset), do: changeset

  def get_search_query(entity, changes)  when map_size(changes) > 0 do
    direct_changes =
      changes
      |> Enum.filter(fn({key, _value}) -> !(key in [:region, :district]) end)
      |> Enum.into(%{})

    query =
      entity
      |> super(direct_changes)
      |> join(:left, [s], r in assoc(s, :region))
      |> join(:left, [s], d in assoc(s, :district))
      |> preload([:region, :district, :parent_settlement])

    query = case Map.has_key?(changes, :region) do
      true -> where(query, [s, r, d], fragment("lower(?)", r.name) == ^String.downcase(Map.get(changes, :region)))
      _ -> query
    end

    case Map.has_key?(changes, :district) do
      true -> where(query, [s, r, d], fragment("lower(?)", d.name) == ^String.downcase(Map.get(changes, :district)))
      _ -> query
    end
  end

  def get_search_query(entity, changes) do
    entity
    |> super(changes)
    |> preload([:region, :district, :parent_settlement])
  end

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:name, :district, :region, :type, :koatuu, :mountain_group])
    |> set_attributes_option([:name, :koatuu], :like)
    |> set_attributes_option([:type], :ignore_case)
  end
end
