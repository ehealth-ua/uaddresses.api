defmodule Uaddresses.Streets do
  @moduledoc """
  The boundary for the Streets system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Paginate

  alias Uaddresses.Repo
  alias Uaddresses.Settlements
  alias Uaddresses.Streets.Street
  alias Uaddresses.Streets.Search

  @street_types [
    "дорога", "урочище", "шлях", "набережна", "вулиця відсутня", "лінія", "квартал", "завулок", "містечко",
    "острів", "спуск", "в’їзд", "майдан", "мікрорайон", "жилий масив", "шосе", "парк", "тупік", "хутір", "проїзд",
    "провулок", "бульвар", "проспект", "узвіз", "вулиця", "площа", "селище"
  ]

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

  def preload_aliases(%Street{} = street), do: Repo.preload(street, :aliases)

  @doc """
  Creates a street.

  ## Examples

      iex> create_street(%{field: value})
      {:ok, %Street{}}

      iex> create_street(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_street(attrs \\ %{}) do
    street_changeset = street_changeset(%Street{}, attrs)
    transaction =
      Repo.transaction(fn ->
        insert_street_result = Repo.insert(street_changeset)
        insert_street_aliases(insert_street_result)
        insert_street_result
      end)

    transaction
    |> build_result()
    |> insert_to_ets()
  end

  def build_result({:ok, transaction_result}), do: transaction_result

  def insert_street_aliases({:error, reason}), do: {:error, reason}
  def insert_street_aliases({:ok, %Street{} = street}) do
    %{street_id: street.id, name: street.name}
    |> street_aliases_changeset()
    |> Repo.insert!()
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
    street_changeset = street_changeset(street, attrs)
    transaction =
      Repo.transaction(fn ->
        update_street_result = Repo.update(street_changeset)
        insert_street_aliases(update_street_result)
        update_street_result
      end)

    transaction
    |> build_result()
    |> insert_to_ets()
  end

  def insert_to_ets({:ok, %Street{} = street}) do
    :ets.insert(:streets,
      {
        street.id,
        street.settlement_id,
        String.downcase(street.name),
        String.downcase(street.type)
      }
    )

    {:ok, street}
  end
  def insert_to_ets({:error, reason}), do: {:error, reason}

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

  defp street_aliases_changeset(attrs) do
    %Uaddresses.Streets.Aliases{}
    |> cast(attrs, [:street_id, :name])
    |> validate_required([:street_id, :name])
  end

  defp street_changeset(%Street{} = street, attrs) do
    street
    |> cast(attrs, [:settlement_id, :type, :name])
    |> validate_required([:settlement_id, :type, :name])
    |> validate_inclusion(:type, @street_types)
    |> validate_settlement_exists(:settlement_id)
  end

  defp validate_settlement_exists(changeset, field) do
    changeset
    |> get_field(field)
    |> Settlements.get_settlement()
    |> result_settlement_exists_validation(changeset)

  end

  defp result_settlement_exists_validation(nil, changeset) do
    add_error(changeset, :settlement_id, "Selected settlement doesn't exists'")
  end
  defp result_settlement_exists_validation(%Uaddresses.Settlements.Settlement{}, changeset), do: changeset

  def search(params) do
    with changeset = %Ecto.Changeset{valid?: true} <- search_changeset(params) do
      {streets, paging} =
        :streets
        |> :ets.match_object(get_match_pattern(changeset.changes))
        |> filter_by_name(params)
        |> Enum.map(fn ({street_id, _, _, _}) -> street_id end)
        |> list_by_ids(params)

      {:ok, streets, paging}
    end
  end

  defp get_match_pattern(changes) do
    {:"$1", changes.settlement_id, :"$3", get_street_type(changes)}
  end

  defp get_street_type(%{type: type}), do: String.downcase(type)
  defp get_street_type(_), do: :"$4"

  defp filter_by_name(list, params) do
    street_name =
      params
      |> Map.get("name", "")
      |> String.downcase()

    Enum.filter(list, fn {_, _, name, _} -> String.contains?(name, street_name) end)
  end

  defp list_by_ids(ids, query_params) do
    {data, paging} =
      Street
      |> where([s], s.id in ^ids)
      |> paginate(query_params)

    {Repo.preload(data, [:settlement, :aliases]), paging}
  end

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:settlement_id, :name, :type])
    |> validate_required([:settlement_id])
  end
end
