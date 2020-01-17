defmodule Lunch.Repo.Migrations.AddOrganizationProfilesTable do
  use Ecto.Migration

  def change do
    create table(:organization_profiles, primary_key: false) do
      add :role, :string
      add(:organization_id, references(:organizations, on_delete: :delete_all), primary_key: true)
      add(:profile_id, references(:profiles, on_delete: :delete_all), primary_key: true)

      timestamps()
    end

    create(index(:organization_profiles, [:organization_id]))
    create(index(:organization_profiles, [:profile_id]))

    create(
      unique_index(:organization_profiles, [:profile_id, :organization_id],
        name: :organization_id_profile_id_unique_index
      )
    )
  end
end
