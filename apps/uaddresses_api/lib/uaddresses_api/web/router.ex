defmodule Uaddresses.Web.Router do
  @moduledoc false

  use Uaddresses.Web, :router

  require Logger

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_secure_browser_headers)
  end

  scope "/", Uaddresses.Web do
    pipe_through(:api)

    resources("/regions", V1.RegionController, only: [:index, :show, :create, :update])
    resources("/districts", V1.DistrictController, only: [:index, :show, :create, :update])
    resources("/settlements", V1.SettlementController, only: [:index, :show, :create, :update])
    resources("/streets", StreetController, only: [:index, :show, :create, :update])

    post("/validate_address", AddressController, :validate)

    get("/regions/:id/districts", V1.RegionController, :districts)
    get("/districts/:id/settlements", V1.DistrictController, :settlements)

    # legacy endpoints for backward compatibility
    get("/details/region/:id/districts", V1.RegionController, :districts)
    get("/details/district/:id/settlements", V1.DistrictController, :settlements)

    get("/search/regions/", V1.RegionController, :index)
    get("/search/districts/", V1.DistrictController, :index)
    get("/search/settlements/", V1.SettlementController, :index)
    get("/search/streets/", StreetController, :index)

    scope "/v2", as: :v2 do
      get("/streets", StreetController, :index)

      resources("/settlements", V2.SettlementController, only: [:index, :show])
      resources("/areas", V2.AreaController, only: [:index, :show])
      resources("/regions", V2.RegionController, only: [:index, :show])

      get("/areas/:id/regions", V2.AreaController, :regions)
      get("/regions/:id/settlements", V2.RegionController, :settlements)
    end
  end
end
