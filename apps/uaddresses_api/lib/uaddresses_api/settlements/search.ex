defmodule Uaddresses.Settlements.Search do
  @moduledoc false

  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:region, :string)
    field(:region_id, :string)
    field(:area, :string)
    field(:type, :string)
    field(:mountain_group, :string)
    field(:koatuu, :string)
  end
end
