defmodule TheLeanCafe.Repo.Migrations.AddCompletedToTopic do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :completed, :boolean, default: false, null: false
    end
  end
end
