defmodule Uaddresses.Settlements.Search do
  use Ecto.Schema
  schema "" do
    field :name, :string
    field :district, :string
    field :region, :string
    field :type, :string
    field :mountain_group, :string
    field :koatuu, :string
  end
end
