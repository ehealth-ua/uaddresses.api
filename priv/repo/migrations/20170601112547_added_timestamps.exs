defmodule Uaddresses.Repo.Migrations.AddedTimestamps do
  use Ecto.Migration

  def change do
    alter table(:streets) do
      timestamps()
    end

    alter table(:settlements) do
      timestamps()
    end

    alter table(:districts) do
      timestamps()
    end

    alter table(:regions) do
      timestamps()
    end
  end
end
