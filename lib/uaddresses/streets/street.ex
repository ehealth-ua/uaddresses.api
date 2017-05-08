defmodule Uaddresses.Streets.Street do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "streets" do
    field :district_id, Ecto.UUID
    field :postal_code, :string
    field :region_id, Ecto.UUID
    field :settlement_id, Ecto.UUID
    field :street_name, :string
    field :street_number, :string
    field :street_type, :string

    has_many :aliases, Uaddresses.Streets.Aliases
  end
end
