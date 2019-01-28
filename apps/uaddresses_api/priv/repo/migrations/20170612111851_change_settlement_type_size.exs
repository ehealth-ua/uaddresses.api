defmodule Uaddresses.Repo.Migrations.ChangeSettlementTypeSize do
  use Ecto.Migration

  def change do
    alter table(:settlements) do
      modify :type, :string, size: 50
    end
  end
end
