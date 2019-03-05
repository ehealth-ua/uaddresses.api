defmodule Uaddresses.Web.SettlementView do
  use Uaddresses.Web, :view

  @fields ~w(
    id
    type
    name
    mountain_group
    koatuu
    region_id
    district_id
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
      region: get_name(settlement.region),
      district: get_name(settlement.district)
    })
  end

  def render("settlement.rpc.json", %{settlement: settlement}) do
    Map.take(settlement, @fields ++ [:inserted_at, :updated_at])
  end

  def render("settlement_by_district.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      settlement_name: settlement.name
    }
  end

  defp get_name(nil), do: nil
  defp get_name(obj), do: obj.name
end
