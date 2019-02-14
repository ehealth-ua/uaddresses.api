defmodule Uaddresses.Factories.DistrictFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def district_factory do
        %Uaddresses.Districts.District{
          name: sequence(:district_name, &"some name #{&1}"),
          region: build(:region)
        }
      end
    end
  end
end
