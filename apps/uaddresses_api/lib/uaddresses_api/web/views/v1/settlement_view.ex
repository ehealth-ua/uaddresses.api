defmodule Uaddresses.Web.V1.SettlementView do
  use Uaddresses.Web, :view

  @fields ~w(
    id
    type
    name
    mountain_group
    koatuu
    parent_settlement_id
  )a

  def render("index.json", %{settlements: settlements}) do
    render_many(settlements, __MODULE__, "settlement.json")
  end

  def render("index.rpc.json", %{settlements: settlements}) do
    render_many(settlements, __MODULE__, "settlement.rpc.json")
  end

  def render("show.json", %{settlement: settlement}) do
    render_one(settlement, __MODULE__, "settlement.json")
  end

  def render("settlement.json", %{settlement: settlement}) do
    settlement
    |> Map.take(@fields)
    |> Map.merge(%{
      parent_settlement: get_name(settlement.parent_settlement),
      region: get_name(settlement.area),
      region_id: settlement.area_id,
      district_id: settlement.region_id,
      district: get_name(settlement.region)
    })
  end

  def render("settlement.rpc.json", %{settlement: settlement}) do
    settlement
    |> Map.take(@fields ++ [:inserted_at, :updated_at])
    |> Map.merge(%{
      region_id: settlement.area_id,
      district_id: settlement.region_id
    })
  end

  def render("settlement_by_district.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      settlement_name: settlement.name
    }
  end

  defp get_name(%{name: name}), do: name
  defp get_name(_), do: nil
end
