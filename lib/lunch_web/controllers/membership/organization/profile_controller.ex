defmodule LunchWeb.Membership.Organization.ProfileController do
  use LunchWeb, :controller

  alias Lunch.Membership
  alias Lunch.Membership.Organization
  alias Lunch.Membership.Profile
  alias Plug.Conn

  plug LunchWeb.CurrentOrganizationPlug
  plug LunchWeb.EnsureUserAuthorizedPlug

  @spec update(Conn.t(), map) :: Conn.t() | no_return()
  def update(%{assigns: %{current_user_is_admin: true}} = conn, %{
        "role" => role,
        "profile_id" => profile_id
      }) do
    message =
      case role do
        "promote" ->
          Membership.promote_profile_to_org_admin(%{id: profile_id}, current_organization(conn))
          gettext("User promoted successfully.")

        "demote" ->
          Membership.demote_profile_to_org_member(%{id: profile_id}, current_organization(conn))
          gettext("User demoted successfully.")

        "remove" ->
          Membership.remove_profile_from_organization(profile_id, current_organization(conn))
          gettext("User removed successfully.")

        _ ->
          gettext("Not an action.")
      end

    _update(conn, message, current_organization(conn).slug)
  end

  def update(conn, %{"role" => "quit"}) do
    Membership.remove_profile_from_organization(
      profile(conn).id,
      current_organization(conn)
    )

    conn
    |> put_flash(:info, gettext("Quit group successfully"))
    |> redirect(to: Routes.page_path(conn, :dashboard))
  end

  defp _update(conn, message, slug) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.organization_path(conn, :show, slug))
  end

  @spec current_organization(Conn.t()) :: Organization.t()
  defp current_organization(conn), do: conn.assigns.current_organization

  @spec profile(Conn.t()) :: Profile.t()
  defp profile(%{assigns: %{current_user: %{profile: profile}}}), do: profile
end
