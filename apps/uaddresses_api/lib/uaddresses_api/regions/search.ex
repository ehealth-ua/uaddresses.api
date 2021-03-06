defmodule Uaddresses.Regions.Search do
  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:koatuu, :string)
    field(:area_id, Ecto.UUID)
    field(:area, :string)
  end
end
