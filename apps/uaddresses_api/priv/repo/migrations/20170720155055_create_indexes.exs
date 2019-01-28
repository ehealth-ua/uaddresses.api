defmodule Uaddresses.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def up do
    execute "CREATE extension if not exists pg_trgm;"
    execute "CREATE INDEX regions_name_index ON regions USING gin (name gin_trgm_ops);"
    execute "CREATE INDEX regions_koatuu_index ON regions USING gin (koatuu gin_trgm_ops);"
    execute "CREATE INDEX districts_name_index ON districts USING gin (name gin_trgm_ops);"
    execute "CREATE INDEX districts_koatuu_index ON districts USING gin (koatuu gin_trgm_ops);"
    execute "CREATE INDEX settlements_name_index ON settlements USING gin (name gin_trgm_ops);"
    execute "CREATE INDEX settlements_koatuu_index ON settlements USING gin (koatuu gin_trgm_ops);"
    execute "CREATE INDEX streets_name_index ON streets USING gin (name gin_trgm_ops);"
  end

  def down do
    execute "DROP INDEX regions_name_index;"
    execute "DROP INDEX regions_koatuu_index;"
    execute "DROP INDEX districts_name_index;"
    execute "DROP INDEX districts_koatuu_index;"
    execute "DROP INDEX settlements_name_index;"
    execute "DROP INDEX settlements_koatuu_index;"
    execute "DROP INDEX streets_name_index;"
  end
end
