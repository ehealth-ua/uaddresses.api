defmodule Uaddresses.Settlements.Settlement do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "settlements" do
    field :name, :string
    field :mountain_group, :string

    timestamps()

    belongs_to :region, Uaddresses.Regions.Region, type: Ecto.UUID
    belongs_to :district, Uaddresses.Districts.District, type: Ecto.UUID
  end
end
