defmodule LunchWeb.ProfileControllerTest do
  use LunchWeb.ConnCase

  alias Lunch.Membership
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo

  @update_attrs %{
    description: "I'm an Elixir Developer who loves BBQ",
    first: "Pattern",
    last: "Toaster",
    slug: "mac2"
  }

  @invalid_attrs %{slug: nil}

  describe "given a user with a profile" do
    setup do
      user = %User{profile: %Profile{slug: "mac"}, username: "mac@example.com"} |> Repo.insert!()

      [user: Membership.get_user(user.id)]
    end

    test "edit profile renders form for editing chosen profile", %{conn: conn} do
      conn = conn |> authed_conn() |> get(Routes.profile_path(conn, :edit))
      assert html_response(conn, 200) =~ "Edit Profile"
    end

    test "update profile redirects when data is valid", %{conn: conn, user: user} do
      updated_conn =
        conn
        |> authed_conn(user)
        |> put(Routes.profile_path(conn, :update), profile: @update_attrs)

      assert redirected_to(updated_conn) == Routes.page_path(updated_conn, :dashboard)
    end

    test "update profile renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> authed_conn(user)
        |> put(Routes.profile_path(conn, :update), profile: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end

  # test "index lists all profiles", %{conn: conn} do
  #   conn = get(conn, profile_path(conn, :index))
  #   assert html_response(conn, 200) =~ "Listing Profiles"
  # end

  # describe "index" do
  #   test "lists all profiles", %{conn: conn} do
  #     conn = get(conn, profile_path(conn, :index))
  #     assert html_response(conn, 200) =~ "Listing Profiles"
  #   end
  # end
end
