defmodule Uaddresses.Web.StreetView do
  use Uaddresses.Web, :view
  alias Uaddresses.Web.StreetView

  @fields ~w(
    id
    name
    type
    settlement_id
  )a

  def render("index.json", %{streets: streets}) do
    render_many(streets, StreetView, "street.json")
  end

  def render("show.json", %{street: street}) do
    render_one(street, StreetView, "street.json")
  end

  def render("index.rpc.json", %{streets: streets}) do
    render_many(streets, __MODULE__, "street.rpc.json")
  end

  def render("street.rpc.json", %{street: street}), do: Map.take(street, @fields ++ [:inserted_at, :updated_at])

  def render("street.json", %{street: street}) do
    %{
      id: street.id,
      settlement_id: street.settlement_id,
      type: street.type,
      name: street.name,
      aliases: render_many(street.aliases, StreetView, "aliases.json")
    }
  end

  def render("aliases.json", %{street: alias_model}) do
    alias_model.name
  end
end
