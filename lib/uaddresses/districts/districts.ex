defmodule Uaddresses.Districts do
  @moduledoc """
  The boundary for the Districts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Uaddresses.Repo

  alias Uaddresses.Districts.District

  @doc """
  Returns the list of districts.

  ## Examples

      iex> list_districts()
      [%District{}, ...]

  """
  def list_districts do
    Repo.all(District)
  end

  def list_by_ids(ids) do
    District
    |> where([d], d.id in ^ids)
    |> Repo.all
    |> Repo.preload(:region)
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
  def get_district!(id), do: Repo.get!(District, id)

  def get_district(nil), do: nil
  def get_district(id), do: Repo.get(District, id)


  def preload_settlements(%District{} = district), do: Repo.preload(district, :settlements)
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
    |> insert_to_ets()
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
    |> insert_to_ets()
  end

  def insert_to_ets({:ok, %District{} = district}) do
    %{region: %{name: region_name}} = Repo.preload(district, :region)

    :ets.insert(:districts,
      {district.id, district.region_id, String.downcase(region_name), String.downcase(district.name)})

    {:ok, district}
  end
  def insert_to_ets({:error, reason}), do: {:error, reason}

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
    |> cast(attrs, [:name, :region_id])
    |> validate_required([:name, :region_id])
    |> validate_region_exists(:region_id)
  end

  defp validate_region_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> Uaddresses.Regions.get_region()
    |> result_region_exists_validation(changeset)
  end

  defp result_region_exists_validation(nil, changeset) do
    add_error(changeset, :region_id, "Selected region doesn't exists'")
  end
  defp result_region_exists_validation(%Uaddresses.Regions.Region{}, changeset), do: changeset

  def search_changeset(attrs) do
    %Uaddresses.Districts.Search{}
    |> cast(attrs, [:region_id, :region, :district])
    |> validate_required([:region])
  end
end
