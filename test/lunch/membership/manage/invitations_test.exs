defmodule Lunch.Membership.Manage.InvitationsTest do
  use Lunch.DataCase
  alias Lunch.Membership
  alias Lunch.Membership.Invitation
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo

  test "change_invitation/1" do
    result = Membership.change_invitation(%Invitation{})
    assert %Ecto.Changeset{} = result
  end

  describe "given an organization exists" do
    setup do
      org = %Organization{slug: "think", name: "Think Company"} |> Repo.insert!()

      [org: org]
    end

    test "create_invitation/2, get_invitation!/2, delete_invitation/1", %{org: org} do
      {:ok, result} = Membership.create_invitation(org.slug, %{"email" => "jawn@philly.com"})

      assert %Invitation{} = result

      invitation = Membership.get_invitation!(org.slug, result.id)

      assert invitation.email == "jawn@philly.com"

      Membership.delete_invitation(invitation)

      assert_raise Ecto.NoResultsError, fn ->
        Membership.get_invitation!(org.slug, result.id)
      end
    end
  end

  describe "given an invitation exists" do
    setup do
      org = %Organization{slug: "think", name: "Think Company"} |> Repo.insert!()
      email = "michael.jackson@example.com"

      user =
        %User{username: "michael.jackson@example.com", profile: %Profile{slug: "mac"}}
        |> Repo.insert!()

      {:ok, invite} = Membership.create_invitation(org.slug, %{"email" => email})

      [invite: invite, org: org, email: email, user: user]
    end

    test "delete_invitation/1", %{invite: invite} do
      {result, _} = Membership.delete_invitation(invite)
      assert result == :ok
      deleted_invite = Invitation |> where([i], i.id == ^invite.id) |> Repo.one()
      assert deleted_invite == nil
    end

    test "invitations_for/1", %{invite: invite, email: email} do
      [item | []] = Membership.invitations_for(email)
      assert item.id == invite.id
    end

    test "accept_invite/1", %{invite: invite, user: user, org: org} do
      {:ok, result} = Membership.accept_invite(invite.id, user)
      assert %Organization{} = result
      assert result.id == org.id

      # Should remove the original invite
      assert user.username |> Membership.invitations_for() |> Enum.count(0)
      # SHould make the user a member
      assert Membership.organization_profile_role(org, user.profile) ==
               OrganizationProfile.member_role()
    end

    test "get_invitation!", %{invite: invite, org: %{slug: slug}} do
      result = Membership.get_invitation!(slug, invite.id)
      assert result == invite
    end
  end
end
