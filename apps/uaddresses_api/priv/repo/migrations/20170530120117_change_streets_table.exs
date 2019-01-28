defmodule Uaddresses.Repo.Migrations.ChangeStreetsTable do
  use Ecto.Migration

  def change do
    rename table(:streets), :street_number, to: :numbers

    alter table(:streets) do
      remove :numbers
      add :numbers, :map
    end

    alter table(:settlements) do
      modify :mountain_group, :string
    end
  end
end
