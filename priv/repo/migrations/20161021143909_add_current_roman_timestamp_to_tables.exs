defmodule TheLeanCafe.Repo.Migrations.AddCurrentRomanTimestampToTables do
  use Ecto.Migration

  def change do
    alter table(:tables) do
      add :current_roman_timestamp, :integer
    end
  end
end
