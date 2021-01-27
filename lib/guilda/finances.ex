defmodule Guilda.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false
  alias Guilda.Repo

  alias Guilda.Finances.Transaction

  defdelegate authorize(action, user, params), to: Guilda.Finances.Policy

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(from t in Transaction, order_by: [desc: t.date])
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Wraps create_transaction/1 in a Bodyguard call. Runs the function
  if the user is authorized to perform the action.
  """
  def create_transaction(user, attrs) do
    case Bodyguard.permit(__MODULE__, :create_transaction, user) do
      :ok ->
        create_transaction(attrs)

      other ->
        other
    end
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:transaction_created)
  end

  @doc """
  Wraps update_transaction/2 in a Bodyguard call. Runs the function
  if the user is authorized to perform the action.
  """
  def update_transaction(user, %Transaction{} = transaction, attrs) do
    case Bodyguard.permit(__MODULE__, :update_transaction, user) do
      :ok ->
        update_transaction(transaction, attrs)

      other ->
        other
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
    |> broadcast(:transaction_updated)
  end

  @doc """
  Wraps delete_transaction/2 in a Bodyguard call. Runs the function
  if the user is authorized to perform the action.
  """
  def delete_transaction(user, %Transaction{} = transaction) do
    case Bodyguard.permit(__MODULE__, :delete_transaction, user) do
      :ok ->
        delete_transaction(transaction)

      other ->
        other
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Guilda.PubSub, "transactions")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, transaction}, event) do
    Phoenix.PubSub.broadcast(Guilda.PubSub, "transactions", {event, transaction})
    {:ok, transaction}
  end
end
