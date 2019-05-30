defmodule Uaddresses.Repo.Migrations.RenameRegionDistrictIndexes do
  use Ecto.Migration

  @disable_ddl_transaction true

  def change do
    execute("ALTER INDEX regions_pkey RENAME TO areas_pkey")
    execute("ALTER INDEX regions_koatuu_index RENAME TO areas_koatuu_index")
    execute("ALTER INDEX regions_name_index RENAME TO areas_name_index")
    execute("ALTER INDEX regions_unique_name_index RENAME TO areas_unique_name_index")
    flush()

    execute("ALTER INDEX districts_koatuu_index RENAME TO regions_koatuu_index")
    execute("ALTER INDEX districts_name_index RENAME TO regions_name_index")
    execute("ALTER INDEX districts_name_region_id_index RENAME TO regions_name_area_id_index")
    execute("ALTER INDEX districts_pkey RENAME TO regions_pkey")
  end
end
