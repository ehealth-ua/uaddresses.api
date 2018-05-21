defmodule Uaddresses.Web.FallbackController do
  @moduledoc """
  This controller should be used as `action_fallback` in rest of controllers to remove duplicated error handling.
  """
  use Uaddresses.Web, :controller
  alias EView.Views.Error
  alias EView.Views.ValidationError

  def call(conn, {:error, :access_denied}) do
    conn
    |> put_status(:unauthorized)
    |> render(Error, :"401")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(Error, :"404")
  end

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> render(Error, :"404")
  end

  def call(conn, {:error, {:"422", message}}) do
    conn
    |> put_status(422)
    |> render(Error, :"400", %{message: message})
  end

  def call(conn, %Ecto.Changeset{valid?: false, data: %Uaddresses.Districts.Search{}} = changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ValidationError, :"422.query", changeset)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ValidationError, :"422", changeset)
  end

  def call(conn, %Ecto.Changeset{valid?: false} = changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ValidationError, :"422", changeset)
  end
end
