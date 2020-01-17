defmodule Lunch.MembershipTest do
  use Lunch.DataCase

  alias Lunch.Membership
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo
  alias Lunch.Signup

  @valid_user_attrs %{password: "some password", username: "some username"}

  describe "Given a user exists in the database" do
    setup do
      {:ok, user} = Signup.create_user(@valid_user_attrs)

      [user: user]
    end

    test "get_user/1 returns a user if found", %{user: user} do
      result = Membership.get_user(user.id)

      assert %User{} = result
      assert result.id == user.id
      assert result.profile == nil
    end

    test "get_user/1 returns nil if not found", %{user: user} do
      result = Membership.get_user(user.id + 1)

      assert is_nil(result)
    end
  end

  describe "given a user with a profile" do
    setup do
      user = %User{profile: %Profile{slug: "mac"}} |> Repo.insert!()

      [user: Membership.get_user(user.id)]
    end

    test "get_user/1 with an existing profile_id", %{user: user} do
      result = Membership.get_profile!(user.profile.id)
      assert result.slug == "mac"
    end

    test "get_user/1 with an non_existing profile_id", %{user: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Membership.get_profile!(user.profile.id + 1)
      end
    end

    test "get_user/1 with an existing profile slug", %{user: user} do
      result = Membership.get_profile!("mac")
      assert result.id == user.profile.id
    end

    test "get_user/1 with an non_existing profile slug" do
      assert_raise Ecto.NoResultsError, fn ->
        Membership.get_profile!("burt_reynolds")
      end
    end
  end
end
