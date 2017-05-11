defmodule Uaddresses.Districts.Search do
  use Ecto.Schema
  schema "" do
    field :district, :string
    field :region_id, Ecto.UUID
    field :region, :string
  end
end
