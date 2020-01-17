defmodule Lunch.Membership do
  @moduledoc """
  Context responsible for managing profile information
  """

  import Ecto.Query
  alias Lunch.Membership.Manage.Invitations, as: ManageInvitations
  alias Lunch.Membership.Manage.Organizations, as: ManageOrganizations
  alias Lunch.Membership.Manage.Profiles, as: ManageProfiles
  alias Lunch.Membership.Manage.Roles, as: ManageRoles
  alias Lunch.Membership.User
  alias Lunch.Repo

  defdelegate change_invitation(invitation), to: ManageInvitations
  defdelegate create_invitation(slug, attrs), to: ManageInvitations
  defdelegate delete_invitation(invitation), to: ManageInvitations
  defdelegate get_invitation!(slug, id), to: ManageInvitations
  defdelegate invitations_for(username), to: ManageInvitations
  defdelegate accept_invite(id, user), to: ManageInvitations

  defdelegate change_organization(org), to: ManageOrganizations
  defdelegate create_organization(profile, attrs), to: ManageOrganizations
  defdelegate delete_organization(org), to: ManageOrganizations
  defdelegate delete_organization(profile, id), to: ManageOrganizations
  defdelegate get_organization!(profile, identifier), to: ManageOrganizations
  defdelegate organization_id_from_slug(slug), to: ManageOrganizations
  defdelegate update_organization(org, attrs), to: ManageOrganizations

  defdelegate add_profile_to_organization(profile, org), to: ManageProfiles
  defdelegate remove_profile_from_organization(profile_id, org), to: ManageProfiles
  defdelegate change_profile(user), to: ManageProfiles
  defdelegate get_profile!(identifier), to: ManageProfiles
  defdelegate list_organizations_for_profile(profile), to: ManageProfiles
  defdelegate update_profile(user, params), to: ManageProfiles

  defdelegate can_demote_admins?(user, org), to: ManageRoles
  defdelegate demote_profile_to_org_member(profile, org), to: ManageRoles
  defdelegate is_organization_admin?(org, user), to: ManageRoles
  defdelegate is_organization_admin?(role), to: ManageRoles
  defdelegate promote_profile_to_org_admin(profile, org), to: ManageRoles
  defdelegate organization_profile_role(profile, org), to: ManageRoles

  @spec get_user(pos_integer | String.t()) :: {:ok, User.t()} | nil
  def get_user(id) do
    User
    |> preload(profile: [:organizations])
    |> where([user], user.id == ^id)
    |> Repo.one()
  end
end
