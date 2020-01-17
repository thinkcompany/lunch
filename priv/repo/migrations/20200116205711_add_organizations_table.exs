defmodule Lunch.Repo.Migrations.AddOrganizationsTable do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :citext
      add :slug, :citext

      timestamps()
    end

    create unique_index(:organizations, [:name])
    create unique_index(:organizations, [:slug])
  end
end
