defmodule Guilda.FinancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Guilda.Finances` context.
  """

  use ExMachina.Ecto, repo: Guilda.Repo

  def transaction_factory do
    %Guilda.Finances.Transaction{
      amount: 20,
      date: Timex.today(),
      note: "some note",
      payee: "some payee"
    }
  end
end
