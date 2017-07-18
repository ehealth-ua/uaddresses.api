defmodule Uaddresses.Settlements do
  @moduledoc """
  The boundary for the Settlements system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Paginate

  alias Uaddresses.Repo
  alias Uaddresses.Districts
  alias Uaddresses.Regions
  alias Uaddresses.Districts.District
  alias Uaddresses.Settlements.Settlement
  alias Uaddresses.Settlements.Search

  @doc """
  Returns the list of settlements.

  ## Examples

      iex> list_settlements()
      [%Settlement{}, ...]

  """
  def list_settlements do
    Settlement
    |> Repo.all()
    |> Repo.preload([:region, :district, :parent_settlement])
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
  def get_settlement!(id) do
    Settlement
    |> Repo.get!(id)
    |> Repo.preload([:region, :district, :parent_settlement])
  end

  def get_settlement(nil), do: nil
  def get_settlement(id) do
    Settlement
    |> Repo.get(id)
    |> Repo.preload([:region, :district, :parent_settlement])
  end

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
    |> preload_embed()
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
    |> preload_embed()
    |> insert_to_ets()
  end

  defp preload_embed({:ok, settlement}), do: {:ok, Repo.preload(settlement, [:region, :district, :parent_settlement])}
  defp preload_embed({:error, reason}), do: {:error, reason}

  def insert_to_ets({:ok, %Settlement{} = settlement}) do
    %{region: %{name: region_name}, district: district} = settlement
    district_name =
      case district do
        nil -> ""
        _ -> district |> Map.get(:name) |> String.downcase()
      end

    :ets.insert(:settlements,
      {
        settlement.id,
        String.downcase(region_name),
        district_name,
        String.downcase(settlement.name),
        String.downcase(to_string(settlement.type)),
        String.downcase(to_string(settlement.mountain_group)),
        String.downcase(to_string(settlement.koatuu))
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
    |> cast(attrs, [:district_id, :region_id, :name, :mountain_group, :type, :koatuu, :parent_settlement_id])
    |> validate_required([:region_id, :name])
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
    |> case do
         nil -> changeset
         field -> field |> Districts.get_district() |> result_district_exists_validation(changeset)
       end
  end

  defp result_district_exists_validation(nil, changeset) do
    add_error(changeset, :district_id, "Selected district doesn't exists'")
  end
  defp result_district_exists_validation(%District{}, changeset), do: changeset

  def search(params) do
    with changeset = %Ecto.Changeset{valid?: true} <- search_changeset(params) do
      {settlements, paging} =
        :settlements
        |> :ets.match_object(get_match_pattern(changeset.changes))
        |> filter_by_name(params)
        |> filter_by_koatuu(params)
        |> Enum.map(fn ({settlement_id, _, _, _, _, _, _}) -> settlement_id end)
        |> list_by_ids(params)

      {:ok, settlements, paging}
    end
  end

  defp get_match_pattern(changes) do
    {:"$1", get_region(changes), get_district(changes), :"$4", get_type(changes), get_mountain_group(changes), :"$7"}
  end

  defp get_region(%{region: region}), do: String.downcase(region)
  defp get_region(_), do: :"$2"

  defp get_district(%{district: district}), do: String.downcase(district)
  defp get_district(_), do: :"$3"

  defp get_type(%{type: type}), do: String.downcase(type)
  defp get_type(_), do: :"$5"

  defp get_mountain_group(%{mountain_group: mountain_group}), do: String.downcase(mountain_group)
  defp get_mountain_group(_), do: :"$6"

  defp filter_by_name(list, params) do
    settlement_name =
      params
      |> Map.get("name", "")
      |> String.downcase()

    Enum.filter(list, fn {_, _, _, name, _, _, _} -> String.contains?(name, settlement_name) end)
  end

  defp filter_by_koatuu(list, params) do
    settlement_koatuu =
      params
      |> Map.get("koatuu", "")
      |> String.downcase()

    Enum.filter(list, fn {_, _, _, _, _, _, koatuu} -> String.contains?(koatuu, settlement_koatuu) end)
  end

  defp list_by_ids(ids, query_params) do
    {data, paging} =
      Settlement
      |> where([s], s.id in ^ids)
      |> paginate(query_params)

    {Repo.preload(data, [:region, :district, :parent_settlement]), paging}
  end

  defp search_changeset(attrs), do: cast(%Search{}, attrs, [:name, :district, :region, :type, :koatuu, :mountain_group])
end
