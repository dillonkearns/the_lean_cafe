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
      assert Table.topics_query(table) == Topic.newest_first_query(table.id)
    end

    test "orders by vote count after closing poll" do
      table = Repo.insert!(%Table{poll_closed: true})
      assert Table.topics_query(table) == Topic.sorted_by_votes_query(table.id)
    end
  end

end
