defmodule Guilda.Repo.Migrations.AddGeomToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :geom, :geometry
    end
  end
end
