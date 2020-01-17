defmodule Lunch.Membership.Manage.Organizations do
  @moduledoc """
  Domain logic for managing organizations.

  These methods should be called through the Membership interface
  """

  import Ecto.Query
  alias Lunch.Membership
  alias Lunch.Membership.Organization
  alias Lunch.Membership.Profile
  alias Lunch.Repo

  defdelegate promote_profile_to_org_admin(profile, org), to: Membership

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{source: %Organization{}}

  """
  @spec change_organization(Organization.t()) :: Ecto.Changeset.t()
  def change_organization(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  @doc """
  Creates a organization with a given profile as the admin.

  ## Examples

      iex> create_organization(profile, %{field: value})
      {:ok, %Organization{}}

      iex> create_organization(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_organization(Profile.t(), map) ::
          {:ok, Organization.t()} | {:error, %Ecto.Changeset{}} | no_return()
  def create_organization(%Profile{} = profile, attrs \\ %{}) do
    case _create_organization(profile, attrs) do
      {:ok, org} -> promote_profile_to_org_admin(profile, org)
      error -> error
    end
  end

  @spec _create_organization(Profile.t(), map) ::
          {:ok, Organization.t()} | {:error, %Ecto.Changeset{}} | no_return()
  defp _create_organization(profile, attrs) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:profiles, [profile])
    |> Repo.insert()
  end

  @doc """
  Deletes a Organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_organization(Organization.t()) ::
          {:ok, Organization.t()} | {:error, Organization.t()}
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Deletes an organization for a specified user.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_organization(Profile.t(), pos_integer) ::
          {:ok, Organization.t()} | {:error, Organization.t()} | no_return()
  def delete_organization(%Profile{} = profile, id) do
    profile
    |> get_organization!(id)
    |> delete_organization()
  end

  @doc """
  Gets a single organization related to a profile.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(profile, 123)
      %Organization{}

      iex> get_organization!(profile, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_organization!(Profile.t(), String.t()) :: Organization.t() | no_return()
  def get_organization!(%Profile{id: profile_id}, slug) when is_binary(slug) do
    Organization
    |> join(:left, [org], profile in assoc(org, :profiles))
    |> where([_, profile], profile.id == ^profile_id)
    |> where([org], org.slug == ^slug)
    |> preload([:invitations, organization_profiles: [profile: [:user]]])
    |> Repo.one()
  end

  @doc """
  Gets a single organization related to a profile.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(profile, 123)
      %Organization{}

      iex> get_organization!(profile, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_organization!(Profile.t(), pos_integer) :: Organization.t() | no_return()
  def get_organization!(%Profile{id: profile_id}, id) when is_integer(id) do
    Organization
    |> join(:left, [org], profile in assoc(org, :profiles))
    |> where([_, profile], profile.id == ^profile_id)
    |> where([org], org.id == ^id)
    |> Repo.one()
  end

  @doc """
  Returns the primary key of the org related to the given slug

  iex> organization_id_from_slug("thinkco")
  1
  """
  @spec organization_id_from_slug(String.t()) :: Organization.t()
  def organization_id_from_slug(slug) do
    Organization
    |> where([org], org.slug == ^slug)
    |> select([org], org.id)
    |> Repo.one()
  end

  @spec update_organization(Organization.t(), map) ::
          {:ok, Organization.t()} | {:error, Organization.t()}
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end
end
