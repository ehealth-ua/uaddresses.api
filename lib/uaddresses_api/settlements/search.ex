defmodule Uaddresses.Settlements.Search do
  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:district, :string)
    field(:district_id, :string)
    field(:region, :string)
    field(:type, :string)
    field(:mountain_group, :string)
    field(:koatuu, :string)
  end
end
