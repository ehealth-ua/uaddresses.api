defmodule Uaddresses.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use Uaddresses.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers

    # Uncomment to enable versioning of your API
    # plug Multiverse, gates: [
    #   "2016-07-31": Uaddresses.Web.InitialGate
    # ]

    # You can allow JSONP requests by uncommenting this line:
    # plug :allow_jsonp
  end

  scope "/", Uaddresses.Web do
    pipe_through :api

    resources "/regions", RegionController, except: [:new, :edit, :delete]
    resources "/districts", DistrictController, except: [:new, :edit, :delete]
    resources "/settlements", SettlementController, except: [:new, :edit, :delete]
    resources "/streets", StreetController, except: [:new, :edit, :delete]

    get "/details/region/:id/districts", RegionController, :districts
    get "/details/district/:id/settlements", DistrictController, :settlements

    get "/search/regions/", RegionController, :index
    get "/search/districts/", DistrictController, :index
    get "/search/settlements/", SettlementController, :index
    get "/search/streets/", StreetController, :index
  end
end
