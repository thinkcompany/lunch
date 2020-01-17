defmodule Lunch.Membership.Manage.Invitations do
  @moduledoc """
  Domain logic for managing invitations to organizations.

  These methods should be called through the Membership interface
  """

  import Ecto.Query
  alias Lunch.Membership
  alias Lunch.Membership.Invitation
  alias Lunch.Membership.Organization
  alias Lunch.Membership.User
  alias Lunch.Repo

  defdelegate organization_id_from_slug(slug), to: Membership

  @spec change_invitation(Invitation.t()) :: Ecto.Changeset.t()
  def change_invitation(%Invitation{} = invitation) do
    Invitation.changeset(invitation, %{})
  end

  @spec create_invitation(String.t(), map) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
  def create_invitation(slug, attrs \\ %{}) do
    attrs = Map.put(attrs, "organization_id", organization_id_from_slug(slug))

    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  @spec delete_invitation(Invitation.t()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  @spec invitations_for(String.t()) :: list(Invitation.t())
  def invitations_for(username) do
    Invitation
    |> where([invitation], invitation.email == ^username)
    |> preload(:organization)
    |> Repo.all()
  end

  @spec accept_invite(pos_integer, User.t()) :: {:ok, Organization.t()} | {:error, any}
  def accept_invite(id, %User{} = user) do
    with %Invitation{} = invitation <- find_invite(id, user),
         {:ok, _} <-
           Membership.add_profile_to_organization(user.profile, invitation.organization),
         {:ok, _} <- delete_invitation(invitation) do
      {:ok, invitation.organization}
    else
      %Ecto.NoResultsError{} -> {:error, "Invitation Not Found"}
      error -> error
    end
  end

  @spec find_invite(pos_integer, User.t()) :: Invitation.t()
  defp find_invite(id, user) do
    Invitation
    |> where([invite], invite.email == ^user.username)
    |> where([invite], invite.id == ^id)
    |> preload(:organization)
    |> Repo.one()
  end

  @spec get_invitation!(String.t(), pos_integer) :: Invitation.t() | no_return
  def get_invitation!(slug, id) do
    Invitation
    |> join(:left, [invitation], organization in assoc(invitation, :organization))
    |> where([_, organization], organization.slug == ^slug)
    |> where([invitation], invitation.id == ^id)
    |> Repo.one!()
  end
end
