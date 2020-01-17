defmodule Lunch.Membership.Profile do
  @moduledoc """
  Public information for users
  """

  use Ecto.Schema
  # use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.User

  @type t :: %__MODULE__{}

  schema "profiles" do
    field(:description, :string)
    field(:first, :string)
    field(:last, :string)
    field(:slug, :string)

    belongs_to(:user, User)
    has_many(:organization_profiles, OrganizationProfile)

    many_to_many(
      :organizations,
      Organization,
      join_through: OrganizationProfile,
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  @spec init_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def init_changeset(info, attrs) do
    info
    |> cast(attrs, [:user_id, :slug])
    |> validate_required([:user_id, :slug])
    |> unique_constraint(:user_id)
    |> unique_constraint(:slug)
  end

  @doc false
  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def changeset(info, attrs) do
    info
    |> cast(attrs, [:first, :last, :slug, :description])
    |> validate_exclusion(:slug, [:edit, :new])
    |> validate_required([:first, :last, :slug])
    |> unique_constraint(:slug)
  end
end
