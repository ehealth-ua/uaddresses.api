defmodule Uaddresses.Streets do
  @moduledoc """
  The boundary for the Streets system.
  """

  import Ecto.{Query, Changeset}, warn: false

  use Uaddresses.Search

  alias Uaddresses.Repo
  alias Uaddresses.Settlements
  alias Uaddresses.Streets.Street
  alias Uaddresses.Streets.Search
  alias Scrivener.Page

  @doc """
  Returns the list of streets.

  ## Examples

      iex> list_streets()
      [%Street{}, ...]

  """
  def list_streets(params) do
    params
    |> search_changeset()
    |> search(params, Street)
    |> preload_aliases()
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
  def preload_aliases({:error, reason}), do: {:error, reason}
  def preload_aliases(%Page{entries: streets} = paging), do: %{paging | entries: Repo.preload(streets, :aliases)}

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

    build_result(transaction)
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

    build_result(transaction)
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

  defp street_aliases_changeset(attrs) do
    %Uaddresses.Streets.Aliases{}
    |> cast(attrs, [:street_id, :name])
    |> validate_required([:street_id, :name])
  end

  defp street_changeset(%Street{} = street, attrs) do
    street
    |> cast(attrs, [:settlement_id, :type, :name])
    |> validate_required([:settlement_id, :type, :name])
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

  defp search_changeset(attrs) do
    %Search{}
    |> cast(attrs, [:settlement_id, :name, :type])
    |> validate_required([:settlement_id])
    |> set_attributes_option([:name], :like)
    |> set_attributes_option([:type], :ignore_case)
  end
end
