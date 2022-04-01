defmodule Guilda.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :action, :string, null: false
      add :ip_address, :inet
      add :user_agent, :string
      add :user_email, :string
      add :params, :map, null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      timestamps(updated_at: false)
    end

    create index(:audit_logs, [:user_id])
  end
end
