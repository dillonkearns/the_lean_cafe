defmodule TheLeanCafe.TopicTest do
  use TheLeanCafe.ModelCase
  import TheLeanCafe.Factory

  alias TheLeanCafe.{Topic, Repo}

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

  test "vote_for creates dot vote for topic" do
    topic = insert(:topic)
    vote =  Topic.vote_for(topic.id) |> Repo.insert!
    assert vote.topic_id == topic.id
  end

  test "get list of topics with dot vote counts" do
    table = insert(:table)
    build(:topic, table: table, name: "Unpopular Topic") |> with_dot_votes(0) |> insert
    build(:topic, table: table, name: "Popular Topic") |> with_dot_votes(3) |> insert
    build(:topic, table: table, name: "Regular Topic") |> with_dot_votes(1) |> insert

    topics_and_votes =
      table.id
      |> Topic.oldest_first_query
      |> Topic.with_vote_counts
      |> Repo.all

    assert [{%Topic{name: "Unpopular Topic"}, 0}, {%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}] = topics_and_votes
  end

  test "sort by dot votes" do
    table = insert(:table)
    build(:topic, table: table, name: "Unpopular Topic") |> with_dot_votes(0) |> insert
    build(:topic, table: table, name: "Popular Topic") |> with_dot_votes(3) |> insert
    build(:topic, table: table, name: "Regular Topic") |> with_dot_votes(1) |> insert

    topics_and_votes =
      Topic.sorted_by_votes_query(table.id)
      |> Topic.with_vote_counts
      |> Repo.all
    assert [{%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}, {%Topic{name: "Unpopular Topic"}, 0}] = topics_and_votes
  end

  test "complete topic" do
    topic = insert(:topic)
    assert !topic.completed
    topic = topic |> Topic.complete |> Repo.update!
    assert topic.completed
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
    current_topic = build(:topic, table: table) |> with_dot_votes(1) |> insert

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
    middle_with_votes = build(:topic, table: table) |> with_dot_votes(1) |> insert
    newest = insert(:topic, table: table)

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
