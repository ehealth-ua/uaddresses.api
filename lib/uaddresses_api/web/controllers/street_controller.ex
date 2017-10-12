defmodule Uaddresses.Web.StreetController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Streets
  alias Uaddresses.Streets.Street
  alias Scrivener.Page

  action_fallback Uaddresses.Web.FallbackController

  def index(conn, params) do
    with %Page{} = paging <- Streets.list_streets(params) do
      render(conn, "index.json", streets: paging.entries, paging: paging)
    end
  end

  def create(conn, %{"street" => street_params}) do
    with {:ok, %Street{} = street} <- Streets.create_street(street_params),
     %Street{} = street = Streets.preload_aliases(street) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", street_path(conn, :show, street))
      |> render("show.json", street: street)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Street{} = street = Streets.get_street!(id),
     %Street{} = street = Streets.preload_aliases(street) do
      render(conn, "show.json", street: street)
    end
  end

  def update(conn, %{"id" => id, "street" => street_params}) do
    street = Streets.get_street!(id)

    with {:ok, %Street{} = street} <- Streets.update_street(street, street_params),
     %Street{} = street = Streets.preload_aliases(street) do
      render(conn, "show.json", street: street)
    end
  end

  def delete(conn, %{"id" => id}) do
    street = Streets.get_street!(id)
    with {:ok, %Street{}} <- Streets.delete_street(street) do
      send_resp(conn, :no_content, "")
    end
  end
end
