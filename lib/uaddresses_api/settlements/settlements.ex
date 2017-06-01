defmodule Uaddresses.Settlements do
  @moduledoc """
  The boundary for the Settlements system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Paginate

  alias Uaddresses.Repo
  alias Uaddresses.Districts
  alias Uaddresses.Regions

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

  def list_settlements_with_regions_and_districts do
    Settlement
    |> Repo.all()
    |> Repo.preload([:region, :district])
  end

  def list_by_ids(ids, query_params) do
    {data, paging} =
      Settlement
      |> where([s], s.id in ^ids)
      |> paginate(query_params)

    {Repo.preload(data, [:region, :district]), paging}
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

  def get_settlements_by_district_id(district_id, query_params) do
    Settlement
    |> where([s], s.district_id == ^district_id)
    |> paginate(query_params)
  end

  def get_by(clauses) do
    Settlement
    |> Repo.get_by(clauses)
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
    |> insert_to_ets()
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
    |> insert_to_ets()
  end

  def insert_to_ets({:ok, %Settlement{} = settlement}) do
    %{region: %{name: region_name}, district: %{name: district_name}} = Repo.preload(settlement, [:region, :district])

    :ets.insert(:settlements,
      {
        settlement.id,
        settlement.region_id,
        settlement.district_id,
        String.downcase(region_name),
        String.downcase(district_name),
        String.downcase(settlement.name)
      }
    )

    {:ok, settlement}
  end
  def insert_to_ets({:error, reason}), do: {:error, reason}

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
    |> cast(attrs, [:district_id, :region_id, :name, :mountain_group])
    |> validate_required([:district_id, :region_id, :name, :mountain_group])
    |> validate_region_exists(:region_id)
    |> validate_district_exists(:district_id)
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
  defp result_region_exists_validation(%Uaddresses.Regions.Region{}, changeset), do: changeset

  defp validate_district_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> Districts.get_district()
    |> result_district_exists_validation(changeset)

  end

  defp result_district_exists_validation(nil, changeset) do
    add_error(changeset, :district_id, "Selected district doesn't exists'")
  end
  defp result_district_exists_validation(%Uaddresses.Districts.District{}, changeset), do: changeset

  def search_changeset(attrs) do
    %Uaddresses.Settlements.Search{}
    |> cast(attrs, [:settlement_name, :district, :region])
    |> validate_required([:region])
  end
end
