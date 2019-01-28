defmodule Uaddresses.Rpc do
  @moduledoc false

  alias EView.Views.ValidationError
  alias Uaddresses.Addresses

  def validate(addresses) when is_list(addresses) do
    with %Ecto.Changeset{valid?: true} <- Addresses.changeset(%Addresses{}, %{"addresses" => addresses}) do
      :ok
    else
      changeset -> {:error, ValidationError.render("422.query.json", changeset)}
    end
  end

  def validate(_) do
    :error
  end
end
