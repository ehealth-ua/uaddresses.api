defmodule Uaddresses.Settlements.Settlement do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "settlements" do
    field :type, :string
    field :name, :string
    field :mountain_group, :boolean
    field :koatuu, :string

    timestamps()

    belongs_to :region, Uaddresses.Regions.Region, type: Ecto.UUID
    belongs_to :district, Uaddresses.Districts.District, type: Ecto.UUID
    belongs_to :parent_settlement, Uaddresses.Settlements.Settlement, type: Ecto.UUID
  end
end
