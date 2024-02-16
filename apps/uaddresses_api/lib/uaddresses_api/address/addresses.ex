defmodule Uaddresses.Addresses do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Uaddresses.Addresses.Address

  @primary_key false
  embedded_schema do
    embeds_many(:addresses, Address)
  end

  def changeset(%__MODULE__{} = addresses, params) do
    addresses
    |> cast(params, [])
    |> cast_embed(:addresses)
  end
end
