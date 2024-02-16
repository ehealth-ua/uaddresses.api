defmodule Uaddresses.Areas do
  @moduledoc """
  The boundary for the Areas system.
  """

  use Uaddresses.Search

  import Ecto.{Query, Changeset}, warn: false

  alias Uaddresses.Areas.Area
  alias Uaddresses.Areas.Search
  alias Uaddresses.Repo

  @doc """
  Returns the list of areas.

  ## Examples

      iex> list_areas()
      [%Area{}, ...]

  """
  def list_areas(params) do
    params
    |> search_changeset()
    |> search(params, Area)
  end

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_area!(123)
      %Area{}

      iex> get_area!(456)
      ** (Ecto.NoResultsError)

  """
  def get_area!(id), do: Repo.get!(Area, id)

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_area(123)
      %Area{}

      iex> get_area(456)
      nil
  """
  def get_area(nil), do: nil
  def get_area(id), do: Repo.get(Area, id)

  @doc """
  Creates an area.

  ## Examples

      iex> create_area(%{field: value})
      {:ok, %Area{}}

      iex> create_area(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_area(attrs \\ %{}) do
    %Area{}
    |> area_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an area.

  ## Examples

      iex> update_area(area, %{field: new_value})
      {:ok, %Area{}}

      iex> update_area(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_area(%Area{} = area, attrs) do
    area
    |> area_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an Area.

  ## Examples

      iex> delete_area(area)
      {:ok, %Area{}}

      iex> delete_area(area)
      {:error, %Ecto.Changeset{}}

  """
  def delete_area(%Area{} = area) do
    Repo.delete(area)
  end

  defp area_changeset(%Area{} = area, attrs) do
    area
    |> cast(attrs, [:name, :koatuu])
    |> validate_required([:name])
    |> unique_constraint(:name, name: "areas_unique_name_index")
  end

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:name, :koatuu])
    |> set_attributes_option([:name, :koatuu], :like)
  end
end
