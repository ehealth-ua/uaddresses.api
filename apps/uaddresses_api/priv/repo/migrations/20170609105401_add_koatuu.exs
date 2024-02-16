defmodule Uaddresses.Repo.Migrations.AddKoatuu do
  use Ecto.Migration

  def change do
    alter table(:settlements) do
      add :koatuu, :string, size: 10
    end

    alter table(:districts) do
      add :koatuu, :string, size: 10
    end

    alter table(:regions) do
      add :koatuu, :string, size: 10
    end
  end
end
