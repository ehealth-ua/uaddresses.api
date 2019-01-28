defmodule Uaddresses.Repo.Migrations.AddStreetIndexes do
  @moduledoc false

  use Ecto.Migration

  def change do
    create(index(:streets, [:settlement_id, "(lower(name))", "(lower(type))"]))
  end
end
