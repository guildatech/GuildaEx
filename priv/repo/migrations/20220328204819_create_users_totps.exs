defmodule Guilda.Repo.Migrations.CreateUsersTotps do
  use Ecto.Migration

  def change do
    create table(:users_totps) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :secret, :binary
      add :backup_codes, :map
      timestamps()
    end

    create unique_index(:users_totps, [:user_id])
  end
end
