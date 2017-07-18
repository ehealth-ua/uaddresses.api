defmodule Uaddresses.Districts do
  @moduledoc """
  The boundary for the Districts system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Paginate

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
  def list_districts do
    District
    |> Repo.all()
    |> Repo.preload(:region)
  end

  def get_by_region_id(region_id, query_params) do
    District
    |> where([s], s.region_id == ^region_id)
    |> paginate(query_params)
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
    |> Repo.get!(id)
    |> Repo.preload(:region)
  end

  def get_district(nil), do: nil
  def get_district(id) do
    District
    |> Repo.get(id)
    |> Repo.preload(:region)
  end

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
    |> preload_region()
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
    |> preload_region()
    |> insert_to_ets()
  end

  def insert_to_ets({:ok, %District{} = district}) do
    %{region: %{name: region_name}} = Repo.preload(district, :region)

    :ets.insert(:districts,
      {district.id, district.region_id, String.downcase(region_name), String.downcase(district.name),
        String.downcase(to_string(district.koatuu))})

    {:ok, district}
  end
  def insert_to_ets({:error, reason}), do: {:error, reason}

  defp preload_region({:ok, district}), do: {:ok, Repo.preload(district, :region)}
  defp preload_region({:error, reason}), do: {:error, reason}

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

  def search(params) do
    with changeset = %Ecto.Changeset{valid?: true} <- search_changeset(params) do
      {districts, paging} =
        :districts
        |> :ets.match_object(get_match_pattern(changeset.changes))
        |> filter_by_name(params)
        |> filter_by_koatuu(params)
        |> Enum.map(fn ({district_id, _, _, _, _}) -> district_id end)
        |> list_by_ids(params)

      {:ok, districts, paging}
    end
  end

  defp get_match_pattern(%{region_id: region_id}) do
    {:"$1", region_id, :"$3", :"$4", :"$5"}
  end
  defp get_match_pattern(%{region: region_name}) do
    {:"$1", :"$2", String.downcase(region_name), :"$4", :"$5"}
  end
  defp get_match_pattern(_) do
    {:"$1", :"$2", :"$3", :"$4", :"$5"}
  end

  defp filter_by_name(list, params) do
    district_name =
      params
      |> Map.get("name", "")
      |> String.downcase()

    Enum.filter(list, fn {_, _, _, name, _} -> String.contains?(name, district_name) end)
  end

  defp filter_by_koatuu(list, params) do
    district_koatuu =
      params
      |> Map.get("koatuu", "")
      |> String.downcase()

    Enum.filter(list, fn {_, _, _, _, koatuu} -> String.contains?(koatuu, district_koatuu) end)
  end

  defp list_by_ids(ids, query_params) do
    {data, paging} = District
    |> where([d], d.id in ^ids)
    |> paginate(query_params)

    {Repo.preload(data, :region), paging}
  end

  defp search_changeset(attrs), do: cast(%Search{}, attrs, [:region_id, :region, :name, :koatuu])
end
