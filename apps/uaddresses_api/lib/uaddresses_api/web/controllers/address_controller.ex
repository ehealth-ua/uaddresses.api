defmodule Uaddresses.Web.AddressController do
  use Uaddresses.Web, :controller

  alias Uaddresses.Addresses
  alias Uaddresses.Addresses.Address

  action_fallback(Uaddresses.Web.FallbackController)

  def validate(conn, %{"addresses" => _} = params) do
    with %Ecto.Changeset{valid?: true} <- Addresses.changeset(%Addresses{}, params) do
      json(conn, %{})
    end
  end

  def validate(conn, %{"address" => address}) do
    with %Ecto.Changeset{valid?: true} <- Address.changeset(%Address{}, address) do
      json(conn, %{})
    end
  end

  def validate(_conn, _params) do
    {:error, {:"422", "Invalid params"}}
  end
end
