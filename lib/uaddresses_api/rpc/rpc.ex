defmodule Uaddresses.Rpc do
  @moduledoc false

  alias EView.Views.ValidationError
  alias Uaddresses.Addresses
  alias Uaddresses.Addresses.Address

  def validate(%{"addresses" => _} = params) do
    with %Ecto.Changeset{valid?: true} <- Addresses.changeset(%Addresses{}, params) do
      :ok
    else
      changeset -> {:error, ValidationError.render("422.query.json", changeset)}
    end
  end

  def validate(%{"address" => address}) do
    with %Ecto.Changeset{valid?: true} <- Address.changeset(%Address{}, address) do
      :ok
    else
      changeset -> {:error, ValidationError.render("422.query.json", changeset)}
    end
  end

  def validate(_) do
    :error
  end
end
