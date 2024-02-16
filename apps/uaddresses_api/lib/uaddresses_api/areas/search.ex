defmodule Uaddresses.Areas.Search do
  @moduledoc false

  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:koatuu, :string)
  end
end
