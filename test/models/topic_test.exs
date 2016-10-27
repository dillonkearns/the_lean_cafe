defmodule TheLeanCafe.TopicTest do
  use TheLeanCafe.ModelCase
  import TheLeanCafe.Factory

  alias TheLeanCafe.{Topic, Repo, DotVote}

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Topic.changeset(%Topic{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Topic.changeset(%Topic{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "get list of topics with dot vote counts" do
    table = insert(:table)
    _topic1 = insert(:topic, table: table, name: "Unpopular Topic")
    topic2 = insert(:topic, table: table, name: "Popular Topic")
    topic3 = insert(:topic, table: table, name: "Regular Topic")
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic3)

    topics_and_votes =
      table.id
      |> Topic.oldest_first_query
      |> Topic.with_vote_counts
      |> Repo.all

    assert [{%Topic{name: "Unpopular Topic"}, 0}, {%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}] = topics_and_votes
  end

  test "sort by dot votes" do
    table = insert(:table)
    _topic1 = insert(:topic, table: table, name: "Unpopular Topic")
    topic2 = insert(:topic, table: table, name: "Popular Topic")
    topic3 = insert(:topic, table: table, name: "Regular Topic")
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic3)

    topics_and_votes =
      Topic.sorted_by_votes_query(table.id)
      |> Topic.with_vote_counts
      |> Repo.all
    assert [{%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}, {%Topic{name: "Unpopular Topic"}, 0}] = topics_and_votes
  end

  test "mark topic as completed by id" do
    topic = insert(:topic, name: "Coding is cool")
    assert !topic.completed
    Topic.complete!(topic)
    topic = Repo.get!(Topic, topic.id)
    assert topic.completed
  end

  test "complete! does not error out for nil" do
    Topic.complete!(nil)
  end

  test "get current topic with no topics" do
    table = insert(:table)

    current = table.id
    |> Topic.sorted_by_votes_query
    |> first
    |> Repo.one

    assert current == nil
  end

  test "get current topic with no votes" do
    table = insert(:table)
    topic = insert(:topic, table: table)

    current = table.id
    |> Topic.sorted_by_votes_query
    |> first
    |> Repo.one

    assert current.id == topic.id
  end

  test "current topic with lots of em" do
    table = insert(:table)
    insert(:topic, table: table, completed: true)
    insert(:topic, table: table)
    current_topic = insert(:topic, table: table)
    Repo.insert!(%DotVote{topic: current_topic})

    current = table.id
    |> Topic.sorted_by_votes_query
    |> first
    |> Repo.one

    assert current.id == current_topic.id
  end

  test "break sort ties by oldest first" do
    table = insert(:table)
    oldest = insert(:topic, table: table)
    middle_no_votes = insert(:topic, table: table)
    middle_with_votes = insert(:topic, table: table)
    newest = insert(:topic, table: table)
    Repo.insert!(%DotVote{topic: middle_with_votes})

    sorted_by_votes = table.id
    |> Topic.sorted_by_votes_query
    |> Repo.all

    map_ids = fn(enum) -> Enum.map(enum, &(&1.id)) end
    expected_order = [
      middle_with_votes,
      oldest,
      middle_no_votes,
      newest,
    ]
    assert map_ids.(sorted_by_votes) == map_ids.(expected_order)
  end

end
