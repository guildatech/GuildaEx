defmodule GuildaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use GuildaWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import GuildaWeb.ConnCase

      alias GuildaWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint GuildaWeb.Endpoint
    end
  end

  defp wait_for_children(children_lookup) when is_function(children_lookup) do
    Process.sleep(100)

    for pid <- children_lookup.() do
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}, 1000
    end
  end

  setup tags do
    pid = Sandbox.start_owner!(Guilda.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)

    on_exit(fn ->
      wait_for_children(fn -> GuildaWeb.Presence.fetchers_pids() end)
    end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Guilda.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that registers and logs in an admin user.

      setup :register_and_log_in_admin_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_admin_user(%{conn: conn}) do
    user = Guilda.AccountsFixtures.user_fixture()
    Guilda.Accounts.give_admin(user)

    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Guilda.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
