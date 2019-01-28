defmodule Uaddresses.Factories.DistrictFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def district_factory do
        %Uaddresses.Districts.District{
          name: "some name",
          region: build(:region)
        }
      end
    end
  end
end
