defmodule Uaddresses.Repo.Migrations.ChangeSettlementsTable do
  use Ecto.Migration

  def change do
    alter table(:settlements) do
      add :type, :string, size: 1
      modify :name, :string, null: false
      modify :district_id, :uuid
      add :parent_settlement, :uuid
    end
  end
end
