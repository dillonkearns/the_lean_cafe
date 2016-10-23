defmodule TheLeanCafe.TopicTest do
  use TheLeanCafe.ModelCase

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

  test "get list of tables with dot vote counts" do
    table = Repo.insert!(%TheLeanCafe.Table{})
    _topic1 = Repo.insert!(%Topic{table_id: table.id, name: "Unpopular Topic"})
    topic2 = Repo.insert!(%Topic{table_id: table.id, name: "Popular Topic"})
    topic3 = Repo.insert!(%Topic{table_id: table.id, name: "Regular Topic"})
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic3)

    topics_and_votes = Topic.with_vote_counts(table.id)
    assert [{%Topic{name: "Unpopular Topic"}, 0}, {%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}] = topics_and_votes
  end

  test "sort by dot votes" do
    table = Repo.insert!(%TheLeanCafe.Table{})
    _topic1 = Repo.insert!(%Topic{table_id: table.id, name: "Unpopular Topic"})
    topic2 = Repo.insert!(%Topic{table_id: table.id, name: "Popular Topic"})
    topic3 = Repo.insert!(%Topic{table_id: table.id, name: "Regular Topic"})
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic3)

    topics_and_votes = Topic.sorted_with_vote_counts(table.id)
    assert [{%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}, {%Topic{name: "Unpopular Topic"}, 0}] = topics_and_votes
  end

  test "mark topic as completed by id" do
    topic = Repo.insert!(%Topic{name: "Coding is cool"})
    assert !topic.completed
    Topic.complete!(topic)
    topic = Repo.get!(Topic, topic.id)
    assert topic.completed
  end
end
