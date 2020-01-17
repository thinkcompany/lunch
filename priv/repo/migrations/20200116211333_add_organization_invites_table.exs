defmodule Lunch.Repo.Migrations.AddOrganizationInvitesTable do
  use Ecto.Migration

  def change do
    create table(:organization_invites) do
      add(:organization_id, references(:organizations, on_delete: :delete_all))
      add :email, :citext

      timestamps()
    end

    create(index(:organization_invites, [:organization_id]))

    create(
      unique_index(:organization_invites, [:email, :organization_id],
        name: :organization_id_email_unique_index
      )
    )
  end
end
