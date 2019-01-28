defmodule Uaddresses.Factories.SettlementFactory do
  @moduledoc false

  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      def settlement_factory do
        %Uaddresses.Settlements.Settlement{
          name: "some name",
          region: build(:region),
          district: build(:district),
          parent_settlement_id: UUID.generate()
        }
      end
    end
  end
end
