defmodule Uaddresses.Regions do
  @moduledoc """
  The boundary for the Regions system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Uaddresses.Repo

  alias Uaddresses.Regions.Region

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_regions()
      [%Region{}, ...]

  """
  def list_regions do
    Repo.all(Region)
  end

  def list_by_ids(ids) do
    Region
    |> where([r], r.id in ^ids)
    |> Repo.all

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

  def insert_to_ets({:ok, %Region{} = region}) do
    :ets.insert(:regions, {region.id, String.downcase(region.name)})
    {:ok, %Region{} = region}
  end
  def insert_to_ets({:error, reason}), do: {:error, reason}

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

  defp region_changeset(%Region{} = region, attrs) do
    region
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
