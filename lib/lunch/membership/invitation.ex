defmodule Lunch.Membership.Invitation do
  @moduledoc """
  Public information for users
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Lunch.Membership.Organization

  @type t :: %__MODULE__{}

  schema "organization_invites" do
    field(:email, :string)
    belongs_to(:organization, Organization, primary_key: true)

    timestamps()
  end

  @doc false
  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def changeset(org_invitation, attrs) do
    org_invitation
    |> cast(attrs, [:email, :organization_id])
    |> validate_required([:email, :organization_id])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:invite_email,
      name: :organization_id_email_unique_index,
      message: "User has already been invited to this organization"
    )
  end
end
