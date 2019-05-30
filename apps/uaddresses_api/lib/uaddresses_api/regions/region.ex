defmodule Uaddresses.Regions.Region do
  use Ecto.Schema

  alias Ecto.UUID
  alias Uaddresses.Areas.Area
  alias Uaddresses.Settlements.Settlement

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "regions" do
    field(:name, :string)
    field(:koatuu, :string)

    belongs_to(:area, Area, type: UUID)
    has_many(:settlements, Settlement)

    timestamps(type: :utc_datetime_usec)
  end
end
