defmodule Uaddresses.Factories.StreetFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def street_factory do
        %Uaddresses.Streets.Street{
          name: "some name",
          type: "вулиця",
          settlement: build(:settlement)
        }
      end
    end
  end
end
