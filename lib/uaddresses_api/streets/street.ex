defmodule Uaddresses.Streets.Street do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "streets" do
    field :name, :string
    field :type, :string

    timestamps()

    has_many :aliases, Uaddresses.Streets.Aliases

    belongs_to :settlement, Uaddresses.Settlements.Settlement, type: Ecto.UUID
  end
end
