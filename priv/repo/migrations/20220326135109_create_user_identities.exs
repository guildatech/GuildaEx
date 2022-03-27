defmodule GuildaWeb.Repo.Migrations.CreateUserIdentities do
  use Ecto.Migration

  def up do
    create table(:user_identities, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false, primary_key: true
      add :provider, :string, null: false, primary_key: true
      add :uid, :string, null: false
      timestamps(updated_at: false)
    end

    create unique_index(:user_identities, [:uid, :provider])

    execute("""
    INSERT INTO user_identities (provider, user_id, uid, inserted_at)
    SELECT 'telegram', u.id, u.telegram_id, now()
    FROM users u
    """)

    alter table(:users) do
      remove :telegram_id
      add :hashed_password, :string
    end
  end

  def down do
    alter table(:users) do
      add :telegram_id, :string
      remove :hashed_password
    end

    execute("""
    UPDATE users
    SET telegram_id = user_identities.uid
    FROM user_identities
    WHERE user_identities.user_id = users.id
    """)

    drop table(:user_identities)
  end
end
