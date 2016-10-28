defmodule TheLeanCafe.TableTest do
  use TheLeanCafe.ModelCase

  alias TheLeanCafe.{Table, Topic, Repo}

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Table.changeset(%Table{}, @valid_attrs)
    assert changeset.valid?
  end

  describe "topics_query" do

    test "orders newest first on a new table" do
      table = Repo.insert!(%Table{})
      assert Table.topics_query(table) == Topic.oldest_first_query(table.id)
    end

    test "orders by vote count after changing state to vote" do
      table = Repo.insert!(%Table{state: "vote"})
      assert Table.topics_query(table) == Topic.sorted_by_votes_query(table.id)
    end
  end

  test "current ignores complete topics" do
    table = Repo.insert!(%Table{})
    Repo.insert!(%Topic{table: table, completed: true})
    incomplete_topic = Repo.insert!(%Topic{table: table})

    current = table
    |> Table.current_topic
    |> Repo.one

    assert current.id == incomplete_topic.id
  end

end
