defmodule Uaddresses.Factories.AreaFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def area_factory do
        %Uaddresses.Areas.Area{
          name: sequence(:area_name, &"some name #{&1}")
        }
      end
    end
  end
end
