defmodule TheLeanCafe.TopicTest do
  use TheLeanCafe.ModelCase

  alias TheLeanCafe.{Topic, Repo, Table, DotVote}

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
    table = Repo.insert!(%TheLeanCafe.Table{})
    _topic1 = Repo.insert!(%Topic{table_id: table.id, name: "Unpopular Topic"})
    topic2 = Repo.insert!(%Topic{table_id: table.id, name: "Popular Topic"})
    topic3 = Repo.insert!(%Topic{table_id: table.id, name: "Regular Topic"})
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic2)
    Topic.vote_for!(topic3)

    topics_and_votes =
      table.id
      |> Topic.newest_first_query
      |> Topic.with_vote_counts
      |> Repo.all

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

    topics_and_votes =
      Topic.sorted_by_votes_query(table.id)
      |> Topic.with_vote_counts
      |> Repo.all
    assert [{%Topic{name: "Popular Topic"}, 3}, {%Topic{name: "Regular Topic"}, 1}, {%Topic{name: "Unpopular Topic"}, 0}] = topics_and_votes
  end

  test "mark topic as completed by id" do
    topic = Repo.insert!(%Topic{name: "Coding is cool"})
    assert !topic.completed
    Topic.complete!(topic)
    topic = Repo.get!(Topic, topic.id)
    assert topic.completed
  end

  test "get current topic with no topics" do
    table = Repo.insert!(%Table{})

    current = table.id
    |> Topic.sorted_by_votes_query
    |> first
    |> Repo.one

    assert current == nil
  end

  test "get current topic with no votes" do
    table = Repo.insert!(%Table{})
    topic = Repo.insert!(%Topic{table: table})

    current = table.id
    |> Topic.sorted_by_votes_query
    |> first
    |> Repo.one

    assert current.id == topic.id
  end


  test "current topic with lots of em" do
    table = Repo.insert!(%Table{})
    Repo.insert!(%Topic{table: table, completed: true})
    Repo.insert!(%Topic{table: table})
    current_topic = Repo.insert!(%Topic{table: table})
    Repo.insert!(%DotVote{topic: current_topic})

    current = table.id
    |> Topic.sorted_by_votes_query
    |> first
    |> Repo.one

    assert current.id == current_topic.id
  end

end
