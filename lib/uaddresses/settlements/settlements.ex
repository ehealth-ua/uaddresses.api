defmodule Uaddresses.Settlements do
  @moduledoc """
  The boundary for the Settlements system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Uaddresses.Repo

  alias Uaddresses.Settlements.Settlement

  @doc """
  Returns the list of settlements.

  ## Examples

      iex> list_settlements()
      [%Settlement{}, ...]

  """
  def list_settlements do
    Repo.all(Settlement)
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
  def get_settlement!(id), do: Repo.get!(Settlement, id)

  def get_settlement(nil), do: nil
  def get_settlement(id), do: Repo.get(Settlement, id)

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
  end

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
    |> cast(attrs, [:district_id, :region_id, :name])
    |> validate_required([:district_id, :region_id, :name])
    |> validate_region_exists(:region_id)
    |> validate_district_exists(:district_id)
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
end
