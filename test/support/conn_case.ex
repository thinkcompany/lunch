defmodule LunchWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Lunch.Repo

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias Lunch.Signup
      alias LunchWeb.Guardian.Tokenizer.Plug, as: GuardianPlug
      alias LunchWeb.Router.Helpers, as: Routes
      alias Plug.Conn

      # The default endpoint for testing
      @endpoint LunchWeb.Endpoint

      @spec authed_conn(Conn.t()) :: Conn.t()
      def authed_conn(conn) do
        user_params = %{password: "some password", username: "some username"}
        {:ok, user} = Signup.create_user(user_params)

        conn
        |> bypass_through(Routes, [:browser, :guardian, :ensure_auth])
        |> GuardianPlug.sign_in(user)
      end

      @spec authed_conn(Conn.t(), Ecto.Schema.t()) :: Conn.t()
      def authed_conn(conn, user) do
        conn
        |> bypass_through(Routes, [:browser, :guardian, :ensure_auth])
        |> GuardianPlug.sign_in(user)
      end
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
