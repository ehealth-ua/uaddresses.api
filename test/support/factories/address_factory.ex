defmodule Uaddresses.Factories.AddressFactory do
  @moduledoc false

  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      def address_factory do
        %{
          type: "RESIDENCE",
          country: "Ukraine",
          area: "Черкаська",
          region: "ЖАШКІВСЬКИЙ",
          settlement: "ЖАШКІВ",
          settlement_type: "CITY",
          settlement_id: UUID.generate(),
          street_type: "STREET",
          street: "some street",
          building: "42",
          apartment: "42",
          zip: "10000"
        }
      end
    end
  end
end
