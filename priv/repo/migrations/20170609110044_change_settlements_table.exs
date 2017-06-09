defmodule Uaddresses.Repo.Migrations.ChangeSettlementsTable do
  use Ecto.Migration

  def change do
    alter table(:settlements) do
      add :type, :string, size: 1
      modify :name, :string, null: false
      modify :district_id, :uuid, null: true
      add :parent_settlement_id, :uuid
    end
  end
end
