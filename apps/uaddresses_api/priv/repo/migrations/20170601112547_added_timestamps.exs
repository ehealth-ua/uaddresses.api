defmodule Uaddresses.Repo.Migrations.AddedTimestamps do
  use Ecto.Migration

  def change do
    alter table(:streets) do
      add :inserted_at, :naive_datetime, default: fragment("now()")
      add :updated_at, :naive_datetime, default: fragment("now()")
    end

    alter table(:settlements) do
      add :inserted_at, :naive_datetime, default: fragment("now()")
      add :updated_at, :naive_datetime, default: fragment("now()")
    end

    alter table(:districts) do
      add :inserted_at, :naive_datetime, default: fragment("now()")
      add :updated_at, :naive_datetime, default: fragment("now()")
    end

    alter table(:regions) do
      add :inserted_at, :naive_datetime, default: fragment("now()")
      add :updated_at, :naive_datetime, default: fragment("now()")
    end
  end
end
