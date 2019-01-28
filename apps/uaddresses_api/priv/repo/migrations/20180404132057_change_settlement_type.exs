defmodule Uaddresses.Repo.Migrations.ChangeSettlementType do
  use Ecto.Migration

  def change do
    execute("UPDATE settlements SET type = 'CITY' where koatuu = '5324255100';")
  end
end
