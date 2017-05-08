defmodule Uaddresses.Settlements.Search do
  use Ecto.Schema
  schema "_" do
    field :settlement_name, :string
    field :district, :string
    field :region, :string
  end
end
