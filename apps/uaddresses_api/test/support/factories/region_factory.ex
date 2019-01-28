defmodule Uaddresses.Factories.RegionFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def region_factory do
        %Uaddresses.Regions.Region{
          name: "some name"
        }
      end
    end
  end
end
