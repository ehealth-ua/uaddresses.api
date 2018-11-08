defmodule Uaddresses.Grpc.Server.Regions do
  @moduledoc false

  alias Uaddresses.Regions.Region
  alias Uaddresses.Repo
  alias UaddressesProto.RegionsRequest
  alias UaddressesProto.RegionsResponse
  alias UaddressesProto.RegionsResponse.Region, as: RegionResponse

  @spec regions(RegionsRequest.t(), GRPS.Server.Stream.t()) :: RegionsResponse.t()
  def regions(%RegionsRequest{}, _) do
    RegionsResponse.new(regions: Enum.map(Repo.all(Region), &struct(RegionResponse, Map.take(&1, ~w(id name koatuu)a))))
  end
end
