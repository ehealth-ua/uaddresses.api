defmodule Uaddresses.Web.V2.SettlementView do
  use Uaddresses.Web, :view

  @fields ~w(
    id
    type
    name
    mountain_group
    koatuu
    area_id
    region_id
    parent_settlement_id
  )a

  def render("index.json", %{settlements: settlements}) do
    render_many(settlements, __MODULE__, "show.json")
  end

  def render("show.json", %{settlement: settlement}) do
    settlement
    |> Map.take(@fields)
    |> Map.merge(%{
      parent_settlement: get_name(settlement.parent_settlement),
      area: get_name(settlement.area),
      region: get_name(settlement.region)
    })
  end

  def render("settlement_by_region.json", %{settlement: settlement}) do
    %{
      id: settlement.id,
      settlement_name: settlement.name
    }
  end

  defp get_name(%{name: name}), do: name
  defp get_name(_), do: nil
end
