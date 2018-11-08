defmodule Uaddresses.Grpc.Server do
  @moduledoc false

  use GRPC.Server, service: UaddressesGrpc.Service

  defdelegate regions(request, stream), to: Uaddresses.Grpc.Server.Regions
end
