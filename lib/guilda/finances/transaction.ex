defmodule Guilda.Finances.Transaction do
  @moduledoc """
  Transaction schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :decimal, default: Decimal.new(0)
    field :date, :date
    field :note, :string
    field :payee, :string
    field :transaction_type, Ecto.Enum, values: ~w(inflow outflow)a, default: :inflow, virtual: true

    field :toggle, :boolean, default: false, virtual: true

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :toggle, :amount, :payee, :note])
    |> validate_required([:date, :amount, :payee])
  end
end
