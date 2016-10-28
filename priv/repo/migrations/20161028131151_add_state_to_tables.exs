defmodule TheLeanCafe.Repo.Migrations.AddStateToTables do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add :state, :string, default: "brainstorm", null: false
      remove :poll_closed
    end
  end
end
