defmodule LunchWeb.ProfileView do
  use LunchWeb, :view

  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Plug.Conn

  @spec display_name(Profile.t() | User.t() | nil) :: iolist | String.t()
  def display_name(%User{profile: %Profile{first: first, last: last} = profile})
      when not (first == "" and last == "") and not (first == nil and last == nil) do
    display_name(profile)
  end

  def display_name(%User{username: username}), do: username

  def display_name(%Profile{first: first, last: last})
      when not (first == "" and last == "") and not (first == nil and last == nil) do
    [first, " ", last]
  end

  def display_name(%Profile{user: %User{username: username}}), do: username

  def display_name(_), do: ""

  @spec demote_member_link(OrganizationProfile.t(), Organization.t(), Conn.t()) ::
          iolist | String.t()
  def demote_member_link(org_profile, org, conn) do
    if conn |> current_user() |> Lunch.Membership.can_demote_admins?(org) do
      link(gettext("(Demote)"), to: change_member_url(org_profile.profile, org, conn, "demote"))
    else
      ""
    end
  end

  @spec promote_member_link(OrganizationProfile.t(), Organization.t(), Conn.t()) ::
          iolist | String.t()
  def promote_member_link(org_profile, org, conn) do
    if current_user_admin?(conn) and not organization_admin?(org_profile) do
      link(gettext("(Promote)"), to: change_member_url(org_profile.profile, org, conn, "promote"))
    else
      ""
    end
  end

  @spec remove_member_link(OrganizationProfile.t(), Organization.t(), Conn.t()) ::
          iolist | String.t()
  def remove_member_link(org_profile, org, conn) do
    if current_user_admin?(conn) and not organization_admin?(org_profile) do
      link(gettext("(Remove)"), to: change_member_url(org_profile.profile, org, conn, "remove"))
    else
      ""
    end
  end

  @spec quit_group_link(OrganizationProfile.t(), Organization.t(), Conn.t()) ::
          iolist | String.t()
  def quit_group_link(org_profile, org, conn) do
    if not organization_admin?(org_profile) and profile_for_current_user?(conn, org_profile) do
      link(gettext("(Quit group)"), to: change_member_url(org_profile.profile, org, conn, "quit"))
    else
      ""
    end
  end

  @spec change_member_url(
          OrganizationProfile.t() | any,
          Organization.t() | any,
          Conn.t(),
          String.t()
        ) ::
          iolist | String.t()
  defp change_member_url(%Profile{} = profile, %Organization{} = org, conn, direction) do
    Routes.organization_role_change_path(conn, :update, org.slug, profile.id, role: direction)
  end

  defp change_member_url(_, _, _, _), do: ""

  @spec organization_admin?(Profile.t() | any) :: boolean
  defp organization_admin?(%Profile{} = profile),
    do: Lunch.Membership.is_organization_admin?(profile.role)

  defp organization_admin?(_), do: false

  @spec profile_for_current_user?(Conn.t(), OrganizationProfile.t()) :: boolean
  defp profile_for_current_user?(conn, org_profile) do
    current_profile(conn).id == org_profile.profile_id
  end
end
