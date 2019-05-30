defmodule Uaddresses.Regions do
  @moduledoc """
  The boundary for the Regions system.
  """

  use Uaddresses.Search
  import Ecto.{Query, Changeset}, warn: false

  alias Uaddresses.Areas
  alias Uaddresses.Regions.Region
  alias Uaddresses.Regions.Search
  alias Uaddresses.Repo

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_regions()
      [%Region{}, ...]

  """
  def list_regions(params) do
    params
    |> search_changeset()
    |> search(params, Region)
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the District does not exist.

  ## Examples

      iex> get_region!(123)
      %Region{}

      iex> get_region!(456)
      ** (Ecto.NoResultsError)

  """
  def get_region!(id) do
    Region
    |> preload(:area)
    |> Repo.get!(id)
  end

  def get_region(nil), do: nil

  def get_region(id) do
    Region
    |> preload(:area)
    |> Repo.get(id)
  end

  defp preload_areas({:ok, region}), do: {:ok, Repo.preload(region, :area)}
  defp preload_areas({:error, reason}), do: {:error, reason}

  @doc """
  Creates a region.

  ## Examples

      iex> create_region(%{field: value})
      {:ok, %Region{}}

      iex> create_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_region(attrs \\ %{}) do
    %Region{}
    |> region_changeset(attrs)
    |> Repo.insert()
    |> preload_areas()
  end

  @doc """
  Updates a region.

  ## Examples

      iex> update_region(region, %{field: new_value})
      {:ok, %Region{}}

      iex> update_region(region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_region(%Region{} = region, attrs) do
    region
    |> region_changeset(attrs)
    |> Repo.update()
    |> preload_areas()
  end

  @doc """
  Deletes a Region.

  ## Examples

      iex> delete_region(region)
      {:ok, %Region{}}

      iex> delete_region(region)
      {:error, %Ecto.Changeset{}}

  """
  def delete_region(%Region{} = region) do
    Repo.delete(region)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking region changes.

  ## Examples

      iex> change_region(region)
      %Ecto.Changeset{source: %Region{}}

  """
  def change_region(%Region{} = region) do
    region_changeset(region, %{})
  end

  defp region_changeset(%Region{} = district, attrs) do
    district
    |> cast(attrs, [:name, :area_id, :koatuu])
    |> validate_required([:name, :area_id])
    |> validate_change(:area_id, fn :area_id, value ->
      if Areas.get_area(value), do: [], else: [:area_id, "Selected region doesn't exists"]
    end)
  end

  def get_search_query(entity, %{area_id: _} = changes) do
    changes =
      changes
      |> Enum.filter(fn {key, _value} -> key != :area end)
      |> Enum.into(%{})

    entity
    |> super(changes)
    |> preload(:area)
  end

  def get_search_query(entity, %{area: area} = changes) do
    changes =
      changes
      |> Enum.filter(fn {key, _value} -> key != :area end)
      |> Enum.into(%{})

    entity
    |> super(changes)
    |> join(:left, [d], r in assoc(d, :area))
    |> preload(:area)
    |> where([d, r], fragment("lower(?)", r.name) == ^String.downcase(area))
  end

  def get_search_query(entity, changes) do
    entity
    |> super(changes)
    |> preload(:area)
  end

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:area_id, :area, :name, :koatuu])
    |> set_attributes_option([:name, :koatuu], :like)
  end
end
