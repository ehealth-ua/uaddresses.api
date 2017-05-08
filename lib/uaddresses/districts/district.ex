defmodule Uaddresses.Districts.District do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "districts" do
    field :name, :string

    belongs_to :region, Uaddresses.Regions.Region, type: Ecto.UUID

    has_many :settlements, Uaddresses.Settlements.Settlement
  end
end
