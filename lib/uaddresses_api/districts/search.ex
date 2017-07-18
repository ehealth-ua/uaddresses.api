defmodule Uaddresses.Districts.Search do
  use Ecto.Schema
  schema "" do
    field :name, :string
    field :koatuu, :string
    field :region_id, Ecto.UUID
    field :region, :string
  end
end
