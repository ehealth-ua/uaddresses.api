defmodule Uaddresses.Repo do
  @moduledoc """
  Repo for Ecto database.

  More info: https://hexdocs.pm/ecto/Ecto.Repo.html
  """
  use Ecto.Repo, otp_app: :uaddresses_api
  use Scrivener, page_size: 10, max_page_size: 500
end
