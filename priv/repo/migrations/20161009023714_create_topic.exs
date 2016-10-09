defmodule TheLeanCafe.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :name, :string
      add :table_id, references(:tables, on_delete: :nothing)

      timestamps()
    end
    create index(:topics, [:table_id])

  end
end
