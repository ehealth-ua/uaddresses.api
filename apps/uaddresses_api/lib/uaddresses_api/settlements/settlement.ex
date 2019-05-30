defmodule Uaddresses.Settlements.Settlement do
  use Ecto.Schema

  alias Ecto.UUID
  alias Uaddresses.Areas.Area
  alias Uaddresses.Regions.Region
  alias Uaddresses.Settlements.Settlement

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "settlements" do
    field(:type, :string)
    field(:name, :string)
    field(:mountain_group, :boolean)
    field(:koatuu, :string)

    belongs_to(:area, Area, type: UUID)
    belongs_to(:region, Region, type: UUID)
    belongs_to(:parent_settlement, Settlement, type: UUID)

    timestamps(type: :utc_datetime_usec)
  end
end
