defmodule Uaddresses.Repo.Migrations.CreateUaddresses.Regions.Region do
  use Ecto.Migration

  def change do
    create table(:regions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 50, null: false
    end
  end
end
