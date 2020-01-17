defmodule Lunch.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :slug, :citext, null: false
      add :first, :string
      add :last, :string
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:profiles, [:slug])
    create index(:profiles, [:user_id])
  end
end
