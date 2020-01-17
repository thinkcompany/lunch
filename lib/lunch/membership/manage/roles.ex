defmodule Lunch.Membership.Manage.Roles do
  @moduledoc """
  Domain logic for managing the roles users have within organizations.

  These methods should be called through the Membership interface
  """

  import Ecto.Query
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo

  @doc """
  Returns a boolean indicating whether the given admin can be demoted.

  We only allow a demotion if there is another admin in teh organization

  iex> can_demote_admins?(profile)
  true
  """
  @spec can_demote_admins?(User.t() | any, Organization.t()) :: boolean
  def can_demote_admins?(%User{} = user, org) do
    org
    |> is_organization_admin?(user)
    |> Kernel.&&(has_multiple_admins?(org))
  end

  def can_demote_admins?(_, _), do: false

  @doc """
  Promotes a given profile to an admin for a given a organization.

  The org/profile relationship needs to already exist for this to work

  ## Examples

      iex> demote_profile_to_org_member(profile, organization)
      {:ok, organization}

  """
  @spec demote_profile_to_org_member(Profile.t() | map, Organization.t()) ::
          {:ok, Organization.t()} | no_return()
  def demote_profile_to_org_member(%{id: profile_id}, %Organization{id: org_id} = org) do
    case change_profile_role(profile_id, org_id, OrganizationProfile.member_role()) do
      {:ok, _} ->
        {:ok, org}

      _ ->
        raise RuntimeError,
          message: "Could not promote profile (#{profile_id}) to admin on org (#{org_id})"
    end
  end

  @doc """
  Returns a boolean indicating whether the given user is an admin of the given org

  iex> is_organization_admin?(%Organziation{}, %User{})
  true
  """
  @spec organization_profile_role(Organization.t(), Profile.t()) :: String.t()
  def organization_profile_role(%Organization{} = org, profile) do
    OrganizationProfile
    |> where([org_profile], org_profile.organization_id == ^org.id)
    |> where([org_profile], org_profile.profile_id == ^profile.id)
    |> select([org_profile], coalesce(org_profile.role, "non_member"))
    |> Repo.one()
  end

  def organization_profile_role(_, _), do: "non_member"

  @doc """
  Returns a boolean indicating whether the given string matched the expected
    admin value

  iex> is_organization_admin?("admin")
  true
  """
  @spec is_organization_admin?(String.t()) :: boolean
  def is_organization_admin?(role), do: role == OrganizationProfile.admin_role()

  @doc """
  Returns a boolean indicating whether the given user is an admin of the given org

  iex> is_organization_admin?(%Organziation{}, %User{})
  true
  """
  @spec is_organization_admin?(Organization.t(), map) :: boolean
  def is_organization_admin?(org, %{profile: profile}) do
    OrganizationProfile
    |> where([org_profile], org_profile.organization_id == ^org.id)
    |> where([org_profile], org_profile.profile_id == ^profile.id)
    |> select(
      [org_profile],
      coalesce(org_profile.role == ^OrganizationProfile.admin_role(), false)
    )
    |> Repo.one()
  end

  @doc """
  Promotes a given profile to an admin for a given a organization.

  The org/profile relationship needs to already exist for this to work

  ## Examples

      iex> promote_profile_to_org_admin(profile, organization)
      {:ok, organization}

  """
  @spec promote_profile_to_org_admin(Profile.t() | map, Organization.t()) ::
          {:ok, Organization.t()} | no_return()
  def promote_profile_to_org_admin(%{id: profile_id}, %Organization{id: org_id} = org) do
    case change_profile_role(profile_id, org_id, OrganizationProfile.admin_role()) do
      {:ok, _} ->
        {:ok, org}

      _ ->
        raise RuntimeError,
          message: "Could not promote profile (#{profile_id}) to admin on org (#{org_id})"
    end
  end

  @spec change_profile_role(pos_integer, pos_integer, String.t()) ::
          {:ok, Organization.t()} | {:error, Organization.t()}
  defp change_profile_role(profile_id, org_id, role) do
    OrganizationProfile
    |> where([op], op.profile_id == ^profile_id and op.organization_id == ^org_id)
    |> Repo.one()
    |> OrganizationProfile.changeset(%{role: role})
    |> Repo.update()
  end

  @spec has_multiple_admins?(Organization.t()) :: boolean
  defp has_multiple_admins?(org) do
    OrganizationProfile
    |> where([org_profile], org_profile.organization_id == ^org.id)
    |> where([org_profile], org_profile.role == ^OrganizationProfile.admin_role())
    |> select([org_profile], count(org_profile.profile_id) > 1)
    |> Repo.one()
  end
end
