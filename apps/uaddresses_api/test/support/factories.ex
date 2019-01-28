defmodule Uaddresses.Factories do
  @moduledoc false

  use ExMachina.Ecto, repo: Uaddresses.Repo
  use Uaddresses.Factories.DistrictFactory
  use Uaddresses.Factories.RegionFactory
  use Uaddresses.Factories.SettlementFactory
  use Uaddresses.Factories.StreetFactory
  use Uaddresses.Factories.AddressFactory
end
