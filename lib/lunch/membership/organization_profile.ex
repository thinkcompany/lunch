defmodule Lunch.Membership.OrganizationProfile do
  @moduledoc """
  The relationship between users and organizations.  These are either admins or
  members
  """

  use Ecto.Schema
  # use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Lunch.Membership.Organization
  alias Lunch.Membership.Profile

  @admin_role "admin"
  @member_role "member"

  @type t :: %__MODULE__{}

  @primary_key false
  schema "organization_profiles" do
    field(:role, :string, default: @member_role)

    belongs_to(:organization, Organization, primary_key: true)
    belongs_to(:profile, Profile, primary_key: true)

    timestamps()
  end

  @doc false
  @spec admin_role() :: String.t()
  def admin_role, do: @admin_role

  @doc false
  @spec member_role() :: String.t()
  def member_role, do: @member_role

  @doc false
  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def changeset(org_profile, attrs) do
    org_profile
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end

  @doc false
  @spec new_role_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def new_role_changeset(org_profile, attrs) do
    org_profile
    |> cast(attrs, [:organization_id, :profile_id])
    |> validate_required([:organization_id, :profile_id])
    |> unique_constraint(:org_profile,
      name: :organization_id_profile_id_unique_index,
      message: "User already belongs to this organization"
    )
  end
end
