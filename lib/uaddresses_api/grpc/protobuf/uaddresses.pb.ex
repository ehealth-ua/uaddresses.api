defmodule UaddressesProto do
  @moduledoc false
  use Protobuf, syntax: :proto3

  defstruct []
end

defmodule UaddressesProto.RegionsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  defstruct []
end

defmodule UaddressesProto.RegionsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          regions: [UaddressesProto.RegionsResponse.Region.t()]
        }
  defstruct [:regions]

  field(:regions, 1, repeated: true, type: UaddressesProto.RegionsResponse.Region)
end

defmodule UaddressesProto.RegionsResponse.Region do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          koatuu: String.t()
        }
  defstruct [:id, :name, :koatuu]

  field(:id, 1, type: :string)
  field(:name, 2, type: :string)
  field(:koatuu, 3, type: :string)
end

defmodule UaddressesGrpc.Service do
  @moduledoc false
  use GRPC.Service, name: "UaddressesGrpc"

  rpc(:Regions, UaddressesProto.RegionsRequest, UaddressesProto.RegionsResponse)
end

defmodule UaddressesGrpc.Stub do
  @moduledoc false
  use GRPC.Stub, service: UaddressesGrpc.Service
end
