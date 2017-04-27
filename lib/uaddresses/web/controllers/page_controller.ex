defmodule Uaddresses.Web.PageController do
  @moduledoc """
  Sample controller for generated application.
  """
  use Uaddresses.Web, :controller

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, _params) do
    render conn, "page.json"
  end
end
