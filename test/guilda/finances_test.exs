defmodule Guilda.FinancesTest do
  use Guilda.DataCase

  alias Guilda.Finances

  describe "transactions" do
    alias Guilda.Finances.Transaction

    @valid_attrs %{amount: "120.5", date: ~D[2010-04-17], note: "some note", payee: "some payee"}
    @update_attrs %{amount: "456.7", date: ~D[2011-05-18], note: "some updated note", payee: "some updated payee"}
    @invalid_attrs %{amount: nil, date: nil, note: nil, payee: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Finances.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Finances.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Finances.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Finances.create_transaction(@valid_attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == ~D[2010-04-17]
      assert transaction.note == "some note"
      assert transaction.payee == "some payee"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finances.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{} = transaction} = Finances.update_transaction(transaction, @update_attrs)
      assert transaction.amount == Decimal.new("456.7")
      assert transaction.date == ~D[2011-05-18]
      assert transaction.note == "some updated note"
      assert transaction.payee == "some updated payee"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.update_transaction(transaction, @invalid_attrs)
      assert transaction == Finances.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Finances.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Finances.change_transaction(transaction)
    end
  end
end
