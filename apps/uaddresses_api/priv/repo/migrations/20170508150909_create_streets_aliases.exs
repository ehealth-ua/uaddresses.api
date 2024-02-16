defmodule Uaddresses.Repo.Migrations.CreateUaddresses.Streets.Aliases do
  use Ecto.Migration

  def change do
    create table(:streets_aliases, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :street_id, :uuid, null: false
      add :name, :string, null: false
    end
  end
end
