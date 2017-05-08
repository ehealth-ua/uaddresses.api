defmodule Uaddresses.Streets do
  @moduledoc """
  The boundary for the Streets system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Uaddresses.Repo

  alias Uaddresses.Streets.Street

  @doc """
  Returns the list of streets.

  ## Examples

      iex> list_streets()
      [%Street{}, ...]

  """
  def list_streets do
    Repo.all(Street)
  end

  @doc """
  Gets a single street.

  Raises `Ecto.NoResultsError` if the Street does not exist.

  ## Examples

      iex> get_street!(123)
      %Street{}

      iex> get_street!(456)
      ** (Ecto.NoResultsError)

  """
  def get_street!(id), do: Repo.get!(Street, id)

  @doc """
  Creates a street.

  ## Examples

      iex> create_street(%{field: value})
      {:ok, %Street{}}

      iex> create_street(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_street(attrs \\ %{}) do
    %Street{}
    |> street_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a street.

  ## Examples

      iex> update_street(street, %{field: new_value})
      {:ok, %Street{}}

      iex> update_street(street, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_street(%Street{} = street, attrs) do
    street
    |> street_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Street.

  ## Examples

      iex> delete_street(street)
      {:ok, %Street{}}

      iex> delete_street(street)
      {:error, %Ecto.Changeset{}}

  """
  def delete_street(%Street{} = street) do
    Repo.delete(street)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking street changes.

  ## Examples

      iex> change_street(street)
      %Ecto.Changeset{source: %Street{}}

  """
  def change_street(%Street{} = street) do
    street_changeset(street, %{})
  end

  defp street_changeset(%Street{} = street, attrs) do
    street
    |> cast(attrs, [:district_id, :region_id, :settlement_id, :street_type, :street_name, :street_number, :postal_code])
    |> validate_required([:district_id, :region_id, :settlement_id, :street_type, :street_name, :street_number, :postal_code])
    |> validate_region_exists(:region_id)
    |> validate_district_exists(:district_id)
    |> validate_settlement_exists(:settlement_id)
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

  defp validate_district_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> Uaddresses.Districts.get_district()
    |> result_district_exists_validation(changeset)

  end

  defp result_district_exists_validation(nil, changeset) do
    add_error(changeset, :district_id, "Selected district doesn't exists'")
  end
  defp result_district_exists_validation(%Uaddresses.Districts.District{}, changeset), do: changeset

  defp validate_settlement_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> Uaddresses.Settlements.get_settlement()
    |> result_settlement_exists_validation(changeset)

  end

  defp result_settlement_exists_validation(nil, changeset) do
    add_error(changeset, :settlement_id, "Selected settlement doesn't exists'")
  end
  defp result_settlement_exists_validation(%Uaddresses.Settlements.Settlement{}, changeset), do: changeset
end
