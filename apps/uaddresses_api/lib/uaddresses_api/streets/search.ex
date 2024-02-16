defmodule Uaddresses.Streets.Search do
  @moduledoc false

  use Ecto.Schema

  embedded_schema do
    field(:settlement_id, Ecto.UUID)
    field(:name, :string)
    field(:type, :string)
  end
end
