defmodule Lunch.Membership.Manage.ProfilesTest do
  use Lunch.DataCase

  alias Ecto.Changeset
  alias Lunch.Membership
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo
  alias Lunch.Signup

  @valid_user_attrs %{password: "some password", username: "some username"}

  describe "given a user without a profile" do
    setup do
      {:ok, user} = Signup.create_user(@valid_user_attrs)

      [user: Membership.get_user(user.id)]
    end

    test "change_profile/1 returns a profile changeset", %{user: user} do
      assert is_nil(user.profile)
      assert %Changeset{} = Membership.change_profile(user)

      updated_user = Membership.get_user(user.id)
      assert %Profile{} = updated_user.profile
      assert "user_#{user.id}" == updated_user.profile.slug
      assert user.id == updated_user.profile.user_id
    end
  end

  describe "given a user with a profile" do
    @update_attrs %{
      description: "I'm an Elixir Developer who loves BBQ",
      first: "Brian",
      last: "McElaney",
      slug: "mac2"
    }

    @invalid_user_attrs %{slug: nil}

    setup do
      user = %User{profile: %Profile{slug: "mac"}} |> Repo.insert!()

      [user: Membership.get_user(user.id)]
    end

    test "change_profile/1 returns a profile changeset", %{user: user} do
      assert user.profile.slug == "mac"
      assert %Changeset{} = Membership.change_profile(user)

      updated_user = Membership.get_user(user.id)
      assert %Profile{} = updated_user.profile
      assert updated_user.profile.slug == "mac"
    end

    test "get_profile!/1 with a slug", %{user: %{profile: profile}} do
      result = Membership.get_profile!(profile.slug)
      assert %Profile{} = result
      assert result.id == profile.id
    end

    test "update_profile/2 with valid_params", %{user: user} do
      Membership.update_profile(user, @update_attrs)
      user = Membership.get_user(user.id)
      assert user.profile.description == "I'm an Elixir Developer who loves BBQ"
      assert user.profile.first == "Brian"
      # assert user.profile.image[:file_name] == "BrianMcElaney.jpg"
      assert user.profile.last == "McElaney"
      assert user.profile.slug == "mac2"
    end

    test "update_profile/2 with invalid_params", %{user: user} do
      result = Membership.update_profile(user, @invalid_user_attrs)
      assert {:error, %Changeset{valid?: false, action: :update}} = result
    end
  end

  describe "given an organization exists" do
    setup do
      %{profile: profile} = %User{profile: %Profile{slug: "mac"}} |> Repo.insert!()
      %{profile: other_profile} = %User{profile: %Profile{slug: "jack"}} |> Repo.insert!()
      org = %Organization{slug: "think", name: "Think Company"} |> Repo.insert!()

      %OrganizationProfile{profile_id: profile.id, organization_id: org.id}
      |> Repo.insert!()

      [other_profile: other_profile, profile: profile, org: org]
    end

    test "list_organizations_for_profile/1 returns a list of organizations", %{
      profile: profile,
      org: org
    } do
      [item | []] = Membership.list_organizations_for_profile(profile)

      assert %Organization{} = item
      assert item.id == org.id
    end

    test "add_profile_to_organization/2 can add members to organizations", %{
      org: org,
      other_profile: other_profile
    } do
      {:ok, profile} = Membership.add_profile_to_organization(other_profile, org)

      assert %Profile{} = profile
      assert other_profile.id == profile.id

      updated_org_profile =
        OrganizationProfile
        |> where([op], op.profile_id == ^profile.id and op.organization_id == ^org.id)
        |> Repo.one()

      assert updated_org_profile.role == OrganizationProfile.member_role()
    end
  end
end
