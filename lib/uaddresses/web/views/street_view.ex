defmodule Uaddresses.Web.StreetView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.StreetView

  def render("index.json", %{streets: streets}) do
    render_many(streets, StreetView, "street.json")
  end

  def render("show.json", %{street: street}) do
    render_one(street, StreetView, "street.json")
  end
  
  def render("search.json", %{streets: streets}) do
    render_many(streets, StreetView, "search_one.json")
  end

  def render("search_one.json", %{street: street}) do
    %{
      id: street.id,
      region: street.region.name,
      district: street.district.name,
      settlement_name: street.settlement.name,
      street_type: street.street_type,
      street_name: street.street_name,
      street_number: street.street_number,
      postal_code: street.postal_code,
      aliases: render_many(street.aliases, StreetView, "aliases.json")
    }
  end

  def render("street.json", %{street: street}) do
    %{id: street.id,
      district_id: street.district_id,
      region_id: street.region_id,
      settlement_id: street.settlement_id,
      street_type: street.street_type,
      street_name: street.street_name,
      street_number: street.street_number,
      postal_code: street.postal_code,
      aliases: render_many(street.aliases, StreetView, "aliases.json")
     }
  end

  def render("aliases.json", %{street: aliasModel}) do
    aliasModel.name
  end
end
