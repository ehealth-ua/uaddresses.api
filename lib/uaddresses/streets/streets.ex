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
    Repo.transaction(fn ->
      insert_street_result = Repo.insert(street_changeset)
      insert_street_aliases(insert_street_result)
      insert_street_result
    end)
    |> build_result()
  end

  def build_result({:ok, transaction_result}), do: transaction_result

  def insert_street_aliases({:error, reason}), do: {:error, reason}
  def insert_street_aliases({:ok, %Street{} = street}) do
    %{street_id: street.id,name: String.downcase(street.street_name)}
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
    Repo.transaction(fn ->
      update_street_result = Repo.update(street_changeset)
      insert_street_aliases(update_street_result)
      update_street_result
    end)
    |> build_result()
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
    |> cast(attrs,
      [:district_id, :region_id, :settlement_id, :street_type, :street_name, :street_number, :postal_code])
    |> validate_required([:district_id, :region_id, :settlement_id, :street_type,
      :street_name, :street_number, :postal_code])
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

  alias Uaddresses.Streets.Aliases

  @doc """
  Returns the list of streets_aliases.

  ## Examples

      iex> list_streets_aliases()
      [%Aliases{}, ...]

  """
  def list_streets_aliases do
    Repo.all(Aliases)
  end

  @doc """
  Gets a single aliases.

  Raises `Ecto.NoResultsError` if the Aliases does not exist.

  ## Examples

      iex> get_aliases!(123)
      %Aliases{}

      iex> get_aliases!(456)
      ** (Ecto.NoResultsError)

  """
  def get_aliases!(id), do: Repo.get!(Aliases, id)

  @doc """
  Creates a aliases.

  ## Examples

      iex> create_aliases(%{field: value})
      {:ok, %Aliases{}}

      iex> create_aliases(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_aliases(attrs \\ %{}) do
    %Aliases{}
    |> aliases_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a aliases.

  ## Examples

      iex> update_aliases(aliases, %{field: new_value})
      {:ok, %Aliases{}}

      iex> update_aliases(aliases, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_aliases(%Aliases{} = aliases, attrs) do
    aliases
    |> aliases_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Aliases.

  ## Examples

      iex> delete_aliases(aliases)
      {:ok, %Aliases{}}

      iex> delete_aliases(aliases)
      {:error, %Ecto.Changeset{}}

  """
  def delete_aliases(%Aliases{} = aliases) do
    Repo.delete(aliases)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking aliases changes.

  ## Examples

      iex> change_aliases(aliases)
      %Ecto.Changeset{source: %Aliases{}}

  """
  def change_aliases(%Aliases{} = aliases) do
    aliases_changeset(aliases, %{})
  end

  defp aliases_changeset(%Aliases{} = aliases, attrs) do
    aliases
    |> cast(attrs, [:street_id, :name])
    |> validate_required([:street_id, :name])
  end
end
