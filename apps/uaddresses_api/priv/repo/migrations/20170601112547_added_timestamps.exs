defmodule Uaddresses.Repo.Migrations.AddedTimestamps do
  use Ecto.Migration

  def change do
    alter table(:streets) do
      timestamps(type: :utc_datetime_usec)
    end

    alter table(:settlements) do
      timestamps(type: :utc_datetime_usec)
    end

    alter table(:districts) do
      timestamps(type: :utc_datetime_usec)
    end

    alter table(:regions) do
      timestamps(type: :utc_datetime_usec)
    end
  end
end
