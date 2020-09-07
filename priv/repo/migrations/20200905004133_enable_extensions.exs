defmodule Guilda.Repo.Migrations.EnableExtensions do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")
    execute("CREATE EXTENSION IF NOT EXISTS citext")
  end

  def down do
    execute("DROP EXTENSION IF EXISTS citext")
    execute("DROP EXTENSION IF EXISTS pgcrypto")
    execute("DROP EXTENSION IF EXISTS \"uuid-ossp\"")
  end
end
