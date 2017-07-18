defmodule Uaddresses.Regions do
  @moduledoc """
  The boundary for the Regions system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Paginate

  alias Uaddresses.Repo
  alias Uaddresses.Regions.Region
  alias Uaddresses.Regions.Search

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_regions()
      [%Region{}, ...]

  """
  def list_regions do
    Repo.all(Region)
  end

  def get_by(clauses) do
    Region
    |> Repo.get_by(clauses)
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the Region does not exist.

  ## Examples

      iex> get_region!(123)
      %Region{}

      iex> get_region!(456)
      ** (Ecto.NoResultsError)

  """
  def get_region!(id), do: Repo.get!(Region, id)

  def preload_districts(%Region{} = region), do: Repo.preload(region, :districts)

  @doc """
    Gets a single region.

    Raises `Ecto.NoResultsError` if the Region does not exist.

    ## Examples

        iex> get_region(123)
        %Region{}

        iex> get_region(456)
        nil
    """
  def get_region(nil), do: nil
  def get_region(id), do: Repo.get(Region, id)

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
    |> insert_to_ets()
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
    |> insert_to_ets()
  end

  def insert_to_ets({:ok, %Region{} = region}) do
    :ets.insert(:regions, {region.id, String.downcase(region.name), String.downcase(to_string(region.koatuu))})

    {:ok, region}
  end
  def insert_to_ets({:error, reason}), do: {:error, reason}

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

  defp region_changeset(%Region{} = region, attrs) do
    region
    |> cast(attrs, [:name, :koatuu])
    |> validate_required([:name])
  end

  def search(params) do
    with %Ecto.Changeset{valid?: true} <- search_changeset(params) do
      {regions, paging} =
        :regions
        |> :ets.match_object({:"$1", :"$2", :"$3"})
        |> filter_by_name(params)
        |> filter_by_koatuu(params)
        |> Enum.map(fn ({region_id, _, _}) -> region_id end)
        |> list_by_ids(params)

      {:ok, regions, paging}
    end
  end

  defp filter_by_name(list, params) do
    region_name =
      params
      |> Map.get("name", "")
      |> String.downcase()

    Enum.filter(list, fn {_, name, _} -> String.contains?(name, region_name) end)
  end

  defp filter_by_koatuu(list, params) do
    region_koatuu =
      params
      |> Map.get("koatuu", "")
      |> String.downcase()

    Enum.filter(list, fn {_, _, koatuu} -> String.contains?(koatuu, region_koatuu) end)
  end

  defp list_by_ids(ids, query_params) do
    Region
    |> where([r], r.id in ^ids)
    |> paginate(query_params)
  end

  defp search_changeset(attrs), do: cast(%Search{}, attrs, [:name, :koatuu])
end
