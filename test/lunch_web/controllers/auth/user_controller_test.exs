defmodule LunchWeb.Auth.UserControllerTest do
  use LunchWeb.ConnCase
  alias Lunch.Membership.User
  alias Lunch.Signup

  @create_attrs %{password: "some password", username: "some username"}
  @invalid_attrs %{password: "some other", username: "some other"}

  describe "Login Form" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.auth_user_path(conn, :new))
      assert html_response(conn, 200) =~ "Log In"
    end
  end

  describe "Given a user exists in the database" do
    setup do
      {:ok, user} = Signup.create_user(@create_attrs)
      [user: user]
    end

    test "redirects to homepage when data is valid", %{conn: conn, user: user} do
      posted_conn = post(conn, Routes.auth_user_path(conn, :create), user: @create_attrs)

      assert redirected_to(posted_conn) == Routes.page_path(posted_conn, :dashboard)

      index_conn = get(posted_conn, Routes.page_path(posted_conn, :dashboard))

      %User{id: id} = index_conn.assigns.current_user
      assert id == user.id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      posted_conn = post(conn, Routes.auth_user_path(conn, :create), user: @invalid_attrs)
      assert html_response(posted_conn, 200) =~ "Log In"

      index_conn = get(posted_conn, Routes.page_path(posted_conn, :index))
      assert is_nil(index_conn.assigns.current_user)
    end

    test "logout", %{conn: conn} do
      posted_conn = post(conn, Routes.auth_user_path(conn, :create), user: @create_attrs)
      deleted_conn = post(posted_conn, Routes.auth_user_path(posted_conn, :delete))

      assert redirected_to(deleted_conn) == Routes.page_path(deleted_conn, :index)

      index_conn = get(deleted_conn, Routes.page_path(deleted_conn, :index))
      assert is_nil(index_conn.assigns.current_user)
    end
  end
end
