defmodule GuildaWeb.Repo.Migrations.AddHashedPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :telegram_id, :string, null: true
      add :hashed_password, :string
    end
  end
end
