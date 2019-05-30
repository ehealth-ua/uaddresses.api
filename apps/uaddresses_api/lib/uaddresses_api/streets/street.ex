defmodule Uaddresses.Streets.Street do
  use Ecto.Schema

  alias Ecto.UUID
  alias Uaddresses.Settlements.Settlement
  alias Uaddresses.Streets.Aliases, as: StreetAliases

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "streets" do
    field(:name, :string)
    field(:type, :string)

    has_many(:aliases, StreetAliases)
    belongs_to(:settlement, Settlement, type: UUID)

    timestamps(type: :utc_datetime_usec)
  end
end
