defmodule Uaddresses.Repo.Migrations.ChangeSettlementsNameIndex do
  use Ecto.Migration

  def change do
    execute "DROP INDEX IF EXISTS settlements_name_index;"
    execute "CREATE INDEX settlements_name_index ON settlements USING gin (lower(name) gin_trgm_ops);"
  end
end
