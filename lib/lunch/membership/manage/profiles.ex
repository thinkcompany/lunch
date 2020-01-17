defmodule Lunch.Membership.Manage.Profiles do
  @moduledoc """
  Domain logic for managing user profiles and their relationships to organizations.

  These methods should be called through the Membership interface
  """

  import Ecto.Query
  alias Lunch.Membership.Organization
  alias Lunch.Membership.OrganizationProfile
  alias Lunch.Membership.Profile
  alias Lunch.Membership.User
  alias Lunch.Repo

  @doc """
  Adds a given profile to a given organization

  The org/profile relationship needs to already exist for this to work

  ## Examples

      iex> add_profile_to_organization(profile, organization)
      {:ok, profile}
  """
  @spec add_profile_to_organization(Profile.t(), Organization.t()) ::
          {:ok, Profile.t()}
  def add_profile_to_organization(%Profile{id: profile_id} = profile, %Organization{id: org_id}) do
    case _add_profile_to_organization(profile_id, org_id) do
      {:ok, _} -> {:ok, profile}
      error -> error
    end
  end

  defp _add_profile_to_organization(profile_id, org_id) do
    %OrganizationProfile{}
    |> OrganizationProfile.new_role_changeset(%{
      organization_id: org_id,
      profile_id: profile_id
    })
    |> Repo.insert()
  end

  @spec remove_profile_from_organization(pos_integer, Organization.t()) :: no_return()
  def remove_profile_from_organization(profile_id, %Organization{id: org_id}) do
    OrganizationProfile
    |> where([op], op.organization_id == ^org_id)
    |> where([op], op.profile_id == ^profile_id)
    |> Repo.one()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  Expects a Membership.User.  If the User has a profile the changeset will be
  for that profile.  Otherwise this method will generate a new profile for the
  user.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{source: %Profile{}}

  """
  @spec change_profile(map) :: Ecto.Changeset.t()
  def change_profile(%{profile: profile}) when not is_nil(profile) do
    Profile.changeset(profile, %{})
  end

  def change_profile(user) do
    %Profile{}
    |> Profile.init_changeset(%{user_id: user.id, slug: "user_#{user.id}"})
    |> Repo.insert!()
    |> Profile.changeset(%{})
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_profile!(pos_integer | String.t()) :: Profile.t()
  def get_profile!(id) when is_integer(id), do: Repo.get!(Profile, id)

  def get_profile!(slug) do
    Profile
    |> where([profile], profile.slug == ^slug)
    |> Repo.one!()
  end

  @doc """
  Returns the list of organizations related to a given profile.

  ## Examples

      iex> list_organizations_for_profile(profile)
      [%Organization{}, ...]

  """
  @spec list_organizations_for_profile(Profile.t()) :: list(Organization.t())
  def list_organizations_for_profile(%Profile{id: profile_id}) do
    Organization
    |> join(:left, [org], profile in assoc(org, :profiles))
    |> where([_, profile], profile.id == ^profile_id)
    |> Repo.all()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_profile(User.t(), map) :: {:ok, Profile.t()} | {:error, Ecto.Changeset.t()}
  def update_profile(%User{profile: profile}, params) when not is_nil(profile) do
    profile
    |> Profile.changeset(params)
    |> Repo.update()
  end
end
