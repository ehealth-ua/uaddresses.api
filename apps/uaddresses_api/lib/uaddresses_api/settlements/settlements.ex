defmodule Uaddresses.Settlements do
  @moduledoc """
  The boundary for the Settlements system.
  """

  use Uaddresses.Search
  import Ecto.{Query, Changeset}, warn: false

  alias Uaddresses.Areas
  alias Uaddresses.Regions
  alias Uaddresses.Repo
  alias Uaddresses.Settlements.Search
  alias Uaddresses.Settlements.Settlement

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
    |> preload([:area, :region, :parent_settlement])
    |> Repo.get!(id)
  end

  def get_settlement(nil), do: nil

  def get_settlement(id) do
    Settlement
    |> preload([:area, :region, :parent_settlement])
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

  defp preload_embed({:ok, settlement}), do: {:ok, Repo.preload(settlement, [:area, :region, :parent_settlement])}

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

  defp settlement_changeset(%Settlement{} = settlement, attrs) do
    settlement
    |> cast(attrs, [
      :region_id,
      :area_id,
      :name,
      :mountain_group,
      :type,
      :koatuu,
      :parent_settlement_id
    ])
    |> validate_required([:area_id, :name])
    |> validate_change(:area_id, fn :area_id, value ->
      if Areas.get_area(value), do: [], else: [:region_id, "Selected region doesn't exists"]
    end)
    |> validate_change(:region_id, fn :region_id, value ->
      if Regions.get_region(value), do: [], else: [:district_id, "Selected district doesn't exists"]
    end)
  end

  def get_search_query(entity, changes) when map_size(changes) > 0 do
    direct_changes =
      changes
      |> Enum.reject(fn {key, _value} -> key in [:area, :region] end)
      |> Enum.into(%{})

    query =
      entity
      |> super(direct_changes)
      |> join(:left, [s], r in assoc(s, :area))
      |> join(:left, [s], d in assoc(s, :region))
      |> preload([:area, :region, :parent_settlement])

    query =
      case Map.has_key?(changes, :area) do
        true ->
          where(
            query,
            [s, r, d],
            fragment("lower(?)", r.name) == ^String.downcase(Map.get(changes, :area))
          )

        _ ->
          query
      end

    case Map.has_key?(changes, :region) do
      true ->
        where(
          query,
          [s, r, d],
          fragment("lower(?)", d.name) == ^String.downcase(Map.get(changes, :region))
        )

      _ ->
        query
    end
  end

  def get_search_query(entity, changes) do
    entity
    |> super(changes)
    |> preload([:area, :region, :parent_settlement])
  end

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:name, :region, :region_id, :area, :type, :koatuu, :mountain_group])
    |> set_attributes_option([:name, :koatuu], :like)
    |> set_attributes_option([:type], :ignore_case)
  end
end
