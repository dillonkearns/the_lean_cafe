defmodule TheLeanCafe.Repo.Migrations.AddCountdownToToTables do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add :countdown_to, :datetime
    end
  end
end
