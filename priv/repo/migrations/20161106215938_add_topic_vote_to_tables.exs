defmodule TheLeanCafe.Repo.Migrations.AddTopicVoteToTables do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add :topic_votes, :map, null: false
    end
  end
end
