defmodule TheLeanCafe.Repo.Migrations.AddTopicsClosedToTables do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add :poll_closed, :boolean
    end
  end

end
