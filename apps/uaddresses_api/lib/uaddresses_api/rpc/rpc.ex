defmodule Uaddresses.Rpc do
  @moduledoc """
  This module contains functions that are called from other pods via RPC.
  """

  import Uaddresses.Web.V1Helper

  alias EView.Views.ValidationError
  alias Uaddresses.Addresses
  alias Uaddresses.Addresses.Address
  alias Uaddresses.Areas
  alias Uaddresses.Areas.Area
  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement
  alias Uaddresses.Streets
  alias Uaddresses.Streets.Street
  alias Uaddresses.Web.StreetView
  alias Uaddresses.Web.V1.DistrictView
  alias Uaddresses.Web.V1.RegionView
  alias Uaddresses.Web.V1.SettlementView

  # TODO: Rename RPC functions according to new naming

  @type settlement_rpc :: %{
          district_id: binary(),
          id: binary(),
          koatuu: binary(),
          mountain_group: boolean(),
          name: binary(),
          parent_settlement_id: binary(),
          region_id: binary(),
          type: binary(),
          inserted_at: DateTime,
          updated_at: DateTime
        }

  @type settlement :: %{
          district: binary(),
          district_id: binary(),
          id: binary(),
          koatuu: binary(),
          mountain_group: boolean(),
          name: binary(),
          parent_settlement: binary(),
          parent_settlement_id: binary(),
          region: binary(),
          region_id: binary(),
          type: binary()
        }

  @type region :: %{
          id: binary(),
          koatuu: binary(),
          name: binary()
        }

  @type district :: %{
          id: binary(),
          koatuu: binary(),
          name: binary(),
          region_id: binary()
        }

  @type street :: %{
          id: binary(),
          type: binary(),
          name: binary()
        }

  @doc """
  Validates given addresses.

      iex> addresses = [%{
      ...>   "apartment" => "23",
      ...>   "area" => "Черкаська",
      ...>   "building" => "15",
      ...>   "country" => "UA",
      ...>   "region" => "ЖАШКІВСЬКИЙ",
      ...>   "settlement" => "some name",
      ...>   "settlement_id" => "aa1d4510-175e-4747-89f1-c68159d07e96",
      ...>   "settlement_type" => "CITY",
      ...>   "street" => "вул. Ніжинська",
      ...>   "street_type" => "STREET",
      ...>   "type" => "RESIDENCE",
      ...>   "zip" => "02090"
      ...> }]
      ...> Uaddresses.Rpc.validate(addresses)

      :ok

  Validates given address.

      iex> address = %{
      ...>   "apartment" => "23",
      ...>   "area" => "Черкаська",
      ...>   "building" => "15",
      ...>   "country" => "UA",
      ...>   "region" => "ЖАШКІВСЬКИЙ",
      ...>   "settlement" => "some name",
      ...>   "settlement_id" => "aa1d4510-175e-4747-89f1-c68159d07e96",
      ...>   "settlement_type" => "CITY",
      ...>   "street" => "вул. Ніжинська",
      ...>   "street_type" => "STREET",
      ...>   "type" => "RESIDENCE",
      ...>   "zip" => "02090"
      ...> }
      ...> Uaddresses.Rpc.validate(address)

      :ok
  """
  @spec validate(list(map) | map()) :: :ok | :error | {:error, map}
  def validate(addresses) when is_list(addresses) do
    case Addresses.changeset(%Addresses{}, %{"addresses" => addresses}) do
      %Ecto.Changeset{valid?: true} -> :ok
      changeset -> {:error, ValidationError.render("422.json", changeset)}
    end
  end

  def validate(address) when is_map(address) do
    case Address.changeset(%Address{}, address) do
      %Ecto.Changeset{valid?: true} -> :ok
      changeset -> {:error, ValidationError.render("422.json", changeset)}
    end
  end

  def validate(_) do
    :error
  end

  @doc """
  Get settlement by id

      iex> Uaddresses.Rpc.settlement_by_id("6604341e-2960-404d-aa07-8552720d7222")

      {:ok,
      %{
        district: "some name 0",
        district_id: "d37b3c31-809b-4a7d-ace2-8ab826df7b09",
        id: "6604341e-2960-404d-aa07-8552720d7222",
        koatuu: nil,
        mountain_group: false,
        name: "some name",
        parent_settlement: nil,
        parent_settlement_id: "c7f12978-9a30-4609-97c5-c9e5fcb42c57",
        region: "some name 0",
        region_id: "8e27e7d7-e85c-444d-b2c6-6e3ae98811da",
        type: nil
      }}
  """
  @spec settlement_by_id(binary()) :: {:ok, settlement()}
  def settlement_by_id(id) do
    with %Settlement{} = settlement <- Settlements.get_settlement(id) do
      {:ok, SettlementView.render("show.json", %{settlement: settlement})}
    end
  end

  @doc """
  Searches for settlements using filtering format.

  Available parameters:

  | Parameter           | Type                          | Example                                   | Description                     |
  | :-----------------: | :---------------------------: | :---------------------------------------: | :-----------------------------: |
  | filter              | `list`                        | `[{:mountain_group, :equal, false}]`      |                                 |
  | order_by            | `list`                        | `[asc: :inserted_at]` or `[desc: :status]`|                                 |
  | cursor              | `{integer, integer}` or `nil` | `{0, 10}`                                 |                                 |

  Example:
      iex> Uaddresses.Rpc.search_settlements([{:koatuu, :equal, "8500000000"}], [asc: :inserted_at], {0, 10})

      {:ok, [
        %{
          district_id: "56cdb8cc-99e1-4b12-b533-d1fa2be4648a",
          id: "74fb7249-7f1e-4076-9bfb-bcfed4a8389c",
          inserted_at: ~N[2019-03-05 08:55:59.396463],
          koatuu: "8500000000",
          mountain_group: false,
          name: "ГАСПРА",
          parent_settlement_id: "6683dc0c-230a-4f03-af40-c75303aa865a",
          region_id: "ac44eb6d-4354-43cb-9852-45b98806a594",
          type: "CITY",
          updated_at: ~N[2019-03-05 08:55:59.396469]
        }]
      }
  """
  @spec search_settlements(list, list, {integer, integer} | nil) :: {:ok, list(settlement_rpc)}
  def search_settlements(filter, order_by \\ [], cursor \\ nil) when filter != [] or is_tuple(cursor) do
    with {:ok, settlements} <- Settlements.search(Settlement, get_filters(filter), order_by, cursor) do
      {:ok, SettlementView.render("index.rpc.json", %{settlements: settlements})}
    end
  end

  @doc """
  Searches for regions using filtering format.

  Available parameters:

  | Parameter           | Type                          | Example                                   | Description                     |
  | :-----------------: | :---------------------------: | :---------------------------------------: | :-----------------------------: |
  | filter              | `list`                        | `[{:name, :equal, "ГАСПРА"}]`             |                                 |
  | order_by            | `list`                        | `[asc: :inserted_at]` or `[desc: :status]`|                                 |
  | cursor              | `{integer, integer}` or `nil` | `{0, 10}`                                 |                                 |

  Example:
      iex> Uaddresses.Rpc.search_regions([{:koatuu, :equal, "8500000001"}], [desc: :inserted_at], {0, 10})

      {:ok, [
        %{
          id: "4494f631-2148-4163-96f8-a9c080c78d77",
          inserted_at: ~N[2019-03-05 08:55:59.460432],
          koatuu: "8500000001",
          name: "ГАСПРА",
          updated_at: ~N[2019-03-05 08:55:59.460446]
        }]
      }
  """
  @spec search_regions(list, list, {integer, integer} | nil) :: {:ok, list(region)}
  def search_regions(filter, order_by \\ [], cursor \\ nil) when filter != [] or is_tuple(cursor) do
    with {:ok, regions} <- Areas.search(Area, get_filters(filter), order_by, cursor) do
      {:ok, RegionView.render("index.rpc.json", %{regions: regions})}
    end
  end

  @doc """
  Searches for districts using filtering format.

  Available parameters:

  | Parameter           | Type                          | Example                                   | Description                     |
  | :-----------------: | :---------------------------: | :---------------------------------------: | :-----------------------------: |
  | filter              | `list`                        | `[{:koatuu, :equal, "8500000002"}]`       |                                 |
  | order_by            | `list`                        | `[asc: :inserted_at]` or `[desc: :status]`|                                 |
  | cursor              | `{integer, integer}` or `nil` | `{0, 10}`                                 |                                 |

  Example:
      iex> Uaddresses.Rpc.search_districts([{:name, :like, "ГАСПРА"}], [desc: :inserted_at], {0, 10})

      {:ok, [
        %{
          id: "5282c084-1015-4404-8d34-9826c502274a",
          inserted_at: ~N[2019-03-05 08:55:59.444467],
          koatuu: "8500000002",
          name: "ГАСПРА",
          region_id: "6d6d0186-16f8-484c-9f68-b9395ec91830",
          updated_at: ~N[2019-03-05 08:55:59.444475]
        }]
      }
  """
  @spec search_districts(list, list, {integer, integer} | nil) :: {:ok, list(district)}
  def search_districts(filter, order_by \\ [], cursor \\ nil) when filter != [] or is_tuple(cursor) do
    with {:ok, districts} <- Regions.search(Region, get_filters(filter), order_by, cursor) do
      {:ok, DistrictView.render("index.rpc.json", %{districts: districts})}
    end
  end

  @doc """
  Searches for districts using filtering format.

  Available parameters:

  | Parameter           | Type                          | Example                                                             | Description                     |
  | :-----------------: | :---------------------------: | :------------------------------------------------------------------:| :-----------------------------: |
  | filter              | `list`                        | `[{:settlement_id, :equal, "eea333b5-e26d-4e3e-92e2-2ab37b131502"}]`|                                 |
  | order_by            | `list`                        | `[asc: :name]` or `[desc: :name]`                                   |                                  |
  | cursor              | `{integer, integer}` or `nil` | `{0, 10}`                                                           |                                 |

  Example:
      iex> Uaddresses.Rpc.search_streets([{:settlement_id, :equal, "eea333b5-e26d-4e3e-92e2-2ab37b131502"}], [desc: :name], {0, 10})

      {:ok, [
        %{
          id: "5282c084-1015-4404-8d34-9826c502274a",
          inserted_at: ~N[2019-03-05 08:55:59.444467],
          name: "Єрмоленка Володимира",
          type: "вул",
          updated_at: ~N[2019-03-05 08:55:59.444475]
        }]
      }
  """
  @spec search_streets(list, list, {integer, integer} | nil) :: {:ok, list(street)}
  def search_streets(filter, order_by \\ [], cursor \\ nil) when filter != [] or is_tuple(cursor) do
    with {:ok, streets} <- Streets.search(Street, get_filters(filter), order_by, cursor) do
      {:ok, StreetView.render("index.rpc.json", %{streets: streets})}
    end
  end

  @doc """
  Update settlement by id

  Example:
      iex> Uaddresses.Rpc.update_settlement("88e44407-6505-45e3-9cee-b4cae8879aae", %{name: "new name"})
      {:ok,
      %{
        district: "some name 14",
        district_id: "6273557f-d7ed-4f72-ba99-763262ae5fe2",
        id: "88e44407-6505-45e3-9cee-b4cae8879aae",
        koatuu: nil,
        mountain_group: false,
        name: "new name",
        parent_settlement: nil,
        parent_settlement_id: "4969a8fe-d469-447e-97e5-d5f84725021d",
        region: "some name 23",
        region_id: "efbd20ec-6f3f-4656-a13a-b12787f45dcb",
        type: nil
      }}
  """
  @spec update_settlement(id :: binary(), params :: map) :: {:ok, settlement} | nil | Ecto.Changeset.t()
  def update_settlement(id, params) do
    with %Settlement{} = settlement <- Settlements.get_settlement(id),
         {:ok, %Settlement{} = settlement} <- Settlements.update_settlement(settlement, params_to_v1(params)) do
      {:ok, SettlementView.render("show.json", %{settlement: settlement})}
    end
  end

  defp get_filters(filter), do: get_filters(%{}, filter)

  defp get_filters(search_fields, []), do: search_fields

  defp get_filters(search_fields, [{:region, _, value} | filter]),
    do: search_fields |> generate_filter(:area, value) |> get_filters(filter)

  defp get_filters(search_fields, [{:region_id, _, value} | filter]),
    do: search_fields |> generate_filter(:area_id, value) |> get_filters(filter)

  defp get_filters(search_fields, [{:district_id, _, value} | filter]),
    do: search_fields |> generate_filter(:region_id, value) |> get_filters(filter)

  defp get_filters(search_fields, [{:district, _, value} | filter]),
    do: search_fields |> generate_filter(:region, value) |> get_filters(filter)

  defp get_filters(search_fields, [{:settlement_id, _, value} | filter]),
    do: search_fields |> generate_filter(:settlement_id, value) |> get_filters(filter)

  defp get_filters(search_fields, [{name, option, value} | filter]),
    do: search_fields |> generate_filter(name, {value, option}) |> get_filters(filter)

  defp generate_filter(map, key, value), do: Map.put_new(map, key, value)
end
