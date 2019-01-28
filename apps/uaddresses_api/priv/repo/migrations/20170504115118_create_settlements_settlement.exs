defmodule Uaddresses.Repo.Migrations.CreateUaddresses.Settlements.Settlement do
  use Ecto.Migration

  def change do
    create table(:settlements, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :district_id, :uuid, null: false
      add :region_id, :uuid, null: false
      add :name, :string, null: false
      add :mountain_group, :boolean, default: false
    end
  end
end
