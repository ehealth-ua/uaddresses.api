defmodule Uaddresses.Streets.Street do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "streets" do
    field :postal_code, :string
    field :street_name, :string
    field :numbers, {:array, :string}
    field :street_type, :string

    timestamps()

    has_many :aliases, Uaddresses.Streets.Aliases

    belongs_to :region, Uaddresses.Regions.Region, type: Ecto.UUID
    belongs_to :settlement, Uaddresses.Settlements.Settlement, type: Ecto.UUID
    belongs_to :district, Uaddresses.Districts.District, type: Ecto.UUID
  end
end
