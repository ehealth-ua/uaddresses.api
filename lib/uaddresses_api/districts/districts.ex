defmodule Uaddresses.Districts do
  @moduledoc """
  The boundary for the Districts system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Search

  alias Uaddresses.Repo
  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region
  alias Uaddresses.Districts.Search
  alias Uaddresses.Districts.District

  @doc """
  Returns the list of districts.

  ## Examples

      iex> list_districts()
      [%District{}, ...]

  """
  def list_districts(params) do
    params
    |> search_changeset()
    |> search(params, District)
  end

  @doc """
  Gets a single district.

  Raises `Ecto.NoResultsError` if the District does not exist.

  ## Examples

      iex> get_district!(123)
      %District{}

      iex> get_district!(456)
      ** (Ecto.NoResultsError)

  """
  def get_district!(id) do
    District
    |> preload(:region)
    |> Repo.get!(id)
  end

  def get_district(nil), do: nil
  def get_district(id) do
    District
    |> preload(:region)
    |> Repo.get(id)
  end

  defp preload_regions({:ok, district}), do: {:ok, Repo.preload(district, :region)}
  defp preload_regions({:error, reason}), do: {:error, reason}
  @doc """
  Creates a district.

  ## Examples

      iex> create_district(%{field: value})
      {:ok, %District{}}

      iex> create_district(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_district(attrs \\ %{}) do
    %District{}
    |> district_changeset(attrs)
    |> Repo.insert()
    |> preload_regions()
  end

  @doc """
  Updates a district.

  ## Examples

      iex> update_district(district, %{field: new_value})
      {:ok, %District{}}

      iex> update_district(district, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_district(%District{} = district, attrs) do
    district
    |> district_changeset(attrs)
    |> Repo.update()
    |> preload_regions()
  end

  @doc """
  Deletes a District.

  ## Examples

      iex> delete_district(district)
      {:ok, %District{}}

      iex> delete_district(district)
      {:error, %Ecto.Changeset{}}

  """
  def delete_district(%District{} = district) do
    Repo.delete(district)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking district changes.

  ## Examples

      iex> change_district(district)
      %Ecto.Changeset{source: %District{}}

  """
  def change_district(%District{} = district) do
    district_changeset(district, %{})
  end

  defp district_changeset(%District{} = district, attrs) do
    district
    |> cast(attrs, [:name, :region_id, :koatuu])
    |> validate_required([:name, :region_id])
    |> validate_region_exists(:region_id)
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

  def get_search_query(entity, %{region_id: _} = changes) do
    changes =
      changes
      |> Enum.filter(fn({key, _value}) -> key != :region end)
      |> Enum.into(%{})

    entity
    |> super(changes)
    |> preload(:region)
  end

  def get_search_query(entity, %{region: region} = changes) do
    changes =
      changes
      |> Enum.filter(fn({key, _value}) -> key != :region end)
      |> Enum.into(%{})

    entity
    |> super(changes)
    |> join(:left, [d], r in assoc(d, :region))
    |> preload(:region)
    |> where([d, r], fragment("lower(?)", r.name) == ^String.downcase(region))
  end

  def get_search_query(entity, changes) do
    entity
    |> super(changes)
    |> preload(:region)
  end

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:region_id, :region, :name, :koatuu])
    |> set_attributes_option([:name, :koatuu], :like)
  end
end
