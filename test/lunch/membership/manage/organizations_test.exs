defmodule Lunch.Membership.Manage.OrganizationsTest do
  use Lunch.DataCase

  alias Lunch.Membership
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo

  @valid_organization_attrs %{name: "WebLinc", slug: "weblinc"}

  test "change_organization/1" do
    result = Membership.change_organization(%Organization{})
    assert %Ecto.Changeset{} = result
  end

  describe "given a user with a profile" do
    setup do
      user = %User{profile: %Profile{slug: "mac"}} |> Repo.insert!()

      [user: Membership.get_user(user.id)]
    end

    test "create_organization/2 allows a user to become an admin of a new org", %{
      user: %{profile: profile}
    } do
      {:ok, result} = Membership.create_organization(profile, @valid_organization_attrs)
      assert result.slug == "weblinc"

      org_profile =
        OrganizationProfile
        |> where([org_profile], org_profile.organization_id == ^result.id)
        |> where([org_profile], org_profile.profile_id == ^profile.id)
        |> Repo.one()

      assert org_profile.role == OrganizationProfile.admin_role()
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

    test "delete_organization/1 with an organization", %{org: org} do
      {result, _} = Membership.delete_organization(org)

      assert result == :ok

      profile_count =
        OrganizationProfile
        |> where([op], op.organization_id == ^org.id)
        |> select([op], count(op.organization_id))
        |> Repo.one()

      assert profile_count == 0

      org_count =
        Organization
        |> where([op], op.id == ^org.id)
        |> select([op], count(op.id))
        |> Repo.one()

      assert org_count == 0
    end

    test "delete_organization/1 with a profile and an organization id", %{
      profile: profile,
      org: org
    } do
      {result, _} = Membership.delete_organization(profile, org.id)

      assert result == :ok

      profile_count =
        OrganizationProfile
        |> where([op], op.organization_id == ^org.id)
        |> select([op], count(op.organization_id))
        |> Repo.one()

      assert profile_count == 0

      org_count =
        Organization
        |> where([op], op.id == ^org.id)
        |> select([op], count(op.id))
        |> Repo.one()

      assert org_count == 0
    end

    test "get_organization!/1 returns an organization given an id", %{profile: profile, org: org} do
      item = Membership.get_organization!(profile, org.id)

      assert %Organization{} = item
      assert item.id == org.id
    end

    test "get_organization!/1 returns an organization given a slug", %{profile: profile, org: org} do
      item = Membership.get_organization!(profile, org.slug)

      assert %Organization{} = item
      assert item.id == org.id
    end

    test "organization_id_from_slug/1", %{org: org} do
      id = Membership.organization_id_from_slug(org.slug)
      assert id == org.id
    end

    test "update_organization/2 updates an organization", %{org: org} do
      {:ok, updated_org} = Membership.update_organization(org, @valid_organization_attrs)

      assert org.id == updated_org.id
      assert updated_org.name == "WebLinc"
    end
  end
end
