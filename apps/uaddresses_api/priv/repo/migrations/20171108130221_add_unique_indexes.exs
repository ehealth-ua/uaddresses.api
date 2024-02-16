defmodule Uaddresses.Repo.Migrations.AddUniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:districts, [:name, :region_id])
  end
end
