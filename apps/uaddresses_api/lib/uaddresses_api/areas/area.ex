defmodule Uaddresses.Areas.Area do
  @moduledoc false

  use Ecto.Schema

  alias Uaddresses.Regions.Region

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "areas" do
    field(:name, :string)
    field(:koatuu, :string)
    has_many(:regions, Region)

    timestamps(type: :utc_datetime_usec)
  end
end
