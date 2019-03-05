defmodule Uaddresses.Rpc do
  @moduledoc """
  This module contains functions that are called from other pods via RPC.
  """

  alias EView.Views.ValidationError
  alias Uaddresses.Addresses
  alias Uaddresses.Districts
  alias Uaddresses.Districts.District
  alias Uaddresses.Regions
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements
  alias Uaddresses.Settlements.Settlement
  alias Uaddresses.Web.DistrictView
  alias Uaddresses.Web.RegionView
  alias Uaddresses.Web.SettlementView

  @type settlement :: %{
          district_id: binary(),
          id: binary(),
          koatuu: binary(),
          mountain_group: boolean(),
          name: binary(),
          parent_settlement_id: binary(),
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

  @doc """
  Validates given address.

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
  """

  @spec validate(list(map)) :: :ok | :error | {:error, map}
  def validate(addresses) when is_list(addresses) do
    with %Ecto.Changeset{valid?: true} <- Addresses.changeset(%Addresses{}, %{"addresses" => addresses}) do
      :ok
    else
      changeset -> {:error, ValidationError.render("422.json", changeset)}
    end
  end

  def validate(_) do
    :error
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
  @spec search_settlements(list, list, {integer, integer} | nil) :: {:ok, list(settlement)}
  def search_settlements(filter, order_by \\ [], cursor \\ nil) when filter != [] or is_tuple(cursor) do
    with {:ok, settlements} <- Settlements.search(Settlement, filter, order_by, cursor) do
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
    with {:ok, regions} <- Regions.search(Region, filter, order_by, cursor) do
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
    with {:ok, districts} <- Districts.search(District, filter, order_by, cursor) do
      {:ok, DistrictView.render("index.rpc.json", %{districts: districts})}
    end
  end
end
