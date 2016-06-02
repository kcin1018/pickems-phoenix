defmodule Pickems.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :is_paid, :boolean, default: false
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:teams, [:owner_id])
    create index(:teams, [:name], unique: true)
  end
end
