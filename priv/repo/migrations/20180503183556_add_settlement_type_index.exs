defmodule Uaddresses.Repo.Migrations.AddSettlementTypeIndex do
  @moduledoc false

  use Ecto.Migration

  def change do
    create(index(:settlements, ["(lower(type))"]))
  end
end
