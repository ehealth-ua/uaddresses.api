defmodule Uaddresses.Streets.Search do
  use Ecto.Schema
  schema "" do
    field :settlement_id, Ecto.UUID
    field :name, :string
    field :type, :string
  end
end
