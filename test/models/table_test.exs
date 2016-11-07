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

    test "orders by vote count after changing state to discuss" do
      table = Repo.insert!(%Table{state: "discuss"})
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

  describe "count vote" do
    test "adds new votes" do
      table = Repo.insert!(%Table{})
      assert table.topic_votes == %{}

      updated_table =
        table
        |> Table.count_vote("username123", "+")
        |> Repo.update!
      assert updated_table.topic_votes == %{"username123" => "+"}
    end

    test "keeps pre-existing votes" do
      table = Repo.insert!(%Table{topic_votes: %{"existinguser" => "-"}})
      assert table.topic_votes == %{"existinguser" => "-"}

      updated_table =
        table
        |> Table.count_vote("newvoteuser", "+")
        |> Repo.update!
      assert updated_table.topic_votes ==
        %{"existinguser" => "-", "newvoteuser" => "+"}
    end

    test "overwrites old votes" do
      table = Repo.insert!(%Table{topic_votes: %{"existingvoteuser" => "-"}})
      assert table.topic_votes == %{"existingvoteuser" => "-"}

      updated_table =
        table
        |> Table.count_vote("existingvoteuser", "+")
        |> Repo.update!
      assert updated_table.topic_votes ==
        %{"existingvoteuser" => "+"}
    end

  end

  test "clear votes" do
    table = Repo.insert!(%Table{topic_votes: %{"existingvoteuser" => "-"}})
    assert table.topic_votes == %{"existingvoteuser" => "-"}

    updated_table =
      table
      |> Table.clear_votes
      |> Repo.update!
    assert updated_table.topic_votes == %{}
    end
end
