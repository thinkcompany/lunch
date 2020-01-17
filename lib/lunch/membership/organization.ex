defmodule Lunch.Membership.Organization do
  @moduledoc """
  Public information for users
  """

  use Ecto.Schema
  # use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Lunch.Membership.Invitation
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile

  @type t :: %__MODULE__{}

  schema "organizations" do
    field(:slug, :string)
    field(:name, :string)

    has_many(:invitations, Invitation)

    many_to_many(
      :profiles,
      Profile,
      join_through: OrganizationProfile,
      on_replace: :delete
    )

    has_many(:organization_profiles, OrganizationProfile)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
