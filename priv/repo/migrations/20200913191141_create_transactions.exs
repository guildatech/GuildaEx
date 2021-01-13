defmodule Guilda.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date, null: false
      add :amount, :decimal, null: false, default: 0
      add :payee, :string, null: false
      add :note, :string

      timestamps()
    end
  end
end
