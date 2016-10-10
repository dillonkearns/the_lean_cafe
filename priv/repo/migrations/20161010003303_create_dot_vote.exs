defmodule TheLeanCafe.Repo.Migrations.CreateDotVote do
  use Ecto.Migration

  def change do
    create table(:dot_votes) do
      add :topic_id, references(:topics, on_delete: :nothing)

      timestamps()
    end
    create index(:dot_votes, [:topic_id])

  end
end
