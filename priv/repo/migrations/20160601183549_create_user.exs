defmodule Pickems.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password_hash, :string
      add :name, :string
      add :admin, :boolean

      timestamps
    end

    create index(:users, [:email], unique: true)
  end
end
