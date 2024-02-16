defmodule Uaddresses.Repo.Migrations.AddRegionNameIndex do
  use Ecto.Migration

  def up do
    create unique_index(:regions, [:name], name: "regions_unique_name_index")
  end

  def down do
    drop index(:regions, [:name])
  end
end
