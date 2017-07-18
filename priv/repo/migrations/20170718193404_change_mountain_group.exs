defmodule Uaddresses.Repo.Migrations.ChangeMountainGroup do
  use Ecto.Migration

  def change do
    execute "alter table settlements alter column mountain_group type boolean using mountain_group::boolean;"
  end
end
