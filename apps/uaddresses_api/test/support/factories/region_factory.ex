defmodule Uaddresses.Factories.RegionFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def region_factory do
        %Uaddresses.Regions.Region{
          name: sequence(:region_name, &"some name #{&1}"),
          area: build(:area)
        }
      end
    end
  end
end
