defmodule LunchWeb.Signup.UserControllerTest do
  use LunchWeb.ConnCase

  alias Lunch.Signup

  @create_attrs %{password: "some password", username: "some username"}
  @invalid_attrs %{password: nil, username: nil}

  @spec fixture(atom) :: Ecto.Schema.t()
  def fixture(:user) do
    {:ok, user} = Signup.create_user(@create_attrs)
    user
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.signup_user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to homepage when data is valid", %{conn: conn} do
      posted_conn = post(conn, Routes.signup_user_path(conn, :create), user: @create_attrs)

      assert redirected_to(posted_conn) == Routes.page_path(posted_conn, :dashboard)

      updated_conn = get(posted_conn, Routes.page_path(posted_conn, :dashboard))

      refute is_nil(updated_conn.assigns.current_user)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      posted_conn = post(conn, Routes.signup_user_path(conn, :create), user: @invalid_attrs)
      assert html_response(posted_conn, 200) =~ "New User"

      updated_conn = get(posted_conn, Routes.page_path(posted_conn, :index))
      assert is_nil(updated_conn.assigns.current_user)
    end
  end
end
