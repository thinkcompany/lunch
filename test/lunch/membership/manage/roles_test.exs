defmodule Lunch.Membership.Manage.RolesTest do
  use Lunch.DataCase

  alias Lunch.Membership
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo

  describe "given an organization exists" do
    setup do
      %{profile: profile} = %User{profile: %Profile{slug: "mac"}} |> Repo.insert!()
      %{profile: other_profile} = %User{profile: %Profile{slug: "jack"}} |> Repo.insert!()
      org = %Organization{slug: "think", name: "Think Company"} |> Repo.insert!()

      %OrganizationProfile{profile_id: profile.id, organization_id: org.id}
      |> Repo.insert!()

      [other_profile: other_profile, profile: profile, org: org]
    end

    test "promote_profile_to_org_admin/2 and demote_profile_to_org_member/2", %{
      profile: profile,
      org: org
    } do
      Membership.promote_profile_to_org_admin(profile, org)

      updated_org_profile =
        OrganizationProfile
        |> where([op], op.profile_id == ^profile.id and op.organization_id == ^org.id)
        |> Repo.one()

      assert updated_org_profile.role == OrganizationProfile.admin_role()

      Membership.demote_profile_to_org_member(profile, org)

      updated =
        OrganizationProfile
        |> where([op], op.profile_id == ^profile.id and op.organization_id == ^org.id)
        |> Repo.one()

      assert updated.role == OrganizationProfile.member_role()
    end

    test "can_demote_admins?/2 && has_multiple_admins?/1", %{
      org: org,
      profile: profile,
      other_profile: other_profile
    } do
      %OrganizationProfile{profile_id: other_profile.id, organization_id: org.id}
      |> Repo.insert!()

      Membership.promote_profile_to_org_admin(profile, org)
      refute Membership.can_demote_admins?(%User{profile: profile}, org)
      Membership.promote_profile_to_org_admin(other_profile, org)
      assert Membership.can_demote_admins?(%User{profile: profile}, org)
    end

    test "is_organization_admin?/1" do
      assert Membership.is_organization_admin?("admin")
      refute Membership.is_organization_admin?("member")
    end

    test "is_organization_admin?/2", %{
      org: org,
      profile: profile
    } do
      refute Membership.is_organization_admin?(org, %{profile: profile})
      Membership.promote_profile_to_org_admin(profile, org)
      assert Membership.is_organization_admin?(org, %{profile: profile})
    end
  end
end
