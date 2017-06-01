defmodule Uaddresses.Streets.Search do
  use Ecto.Schema
  schema "" do
    field :settlement_name, :string
    field :settlement_id, Ecto.UUID
    field :street_name, :string
    field :street_type, :string
    field :numbers, :string
    field :postal_code, :string
    field :region, :string
    field :district, :string
  end
end
