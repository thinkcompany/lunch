defmodule LunchWeb.CurrentOrganizationPlug do
  @moduledoc """
  Plug that populates the current_organization assigns
  """

  alias Lunch.Membership
  alias Lunch.Membership.Organization
  alias Lunch.Membership.Profile
  alias Plug.Conn

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Conn.t(), any) :: Conn.t()
  def call(conn, _opts) do
    organization = fetch_organization_from_url(conn)
    role = conn |> profile() |> user_role(organization)

    conn
    |> Conn.assign(:current_organization, organization)
    |> Conn.assign(:current_user_is_member, member?(role))
    |> Conn.assign(:current_user_is_admin, admin?(role))
  end

  @spec fetch_organization_from_url(Conn.t()) :: Organization.t()
  def fetch_organization_from_url(%{path_info: ["o", slug | _]} = conn) do
    conn |> profile() |> Membership.get_organization!(slug)
  end

  def fetch_organization_from_url(_), do: nil

  @spec profile(Conn.t()) :: Profile.t()
  defp profile(%{assigns: %{current_user: %{profile: profile}}}), do: profile
  defp profile(_), do: nil

  @spec user_role(Profile.t(), Organization.t()) :: String.t()
  defp user_role(profile, org) do
    Membership.organization_profile_role(org, profile)
  end

  @spec member?(String.t()) :: boolean
  defp member?("non_member"), do: false
  defp member?(_), do: true

  @spec admin?(String.t()) :: boolean
  defp admin?(role), do: Membership.is_organization_admin?(role)
end
