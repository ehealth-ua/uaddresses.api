defmodule Uaddresses.Regions.Region do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "regions" do
    field(:name, :string)
    field(:koatuu, :string)
    has_many(:districts, Uaddresses.Districts.District)

    timestamps(type: :utc_datetime)
  end
end
