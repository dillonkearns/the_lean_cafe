defmodule TheLeanCafe.TableTest do
  use TheLeanCafe.ModelCase

  alias TheLeanCafe.{Table, Repo, Topic}

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Table.changeset(%Table{}, @valid_attrs)
    assert changeset.valid?
  end

  test "get current topic with no topics" do
    table = Repo.insert!(%Table{})

    assert Table.current_topic(table.id) == nil
  end

  test "get current topic" do
    table = Repo.insert!(%Table{})
    topic = Repo.insert!(%Topic{table: table})

    assert Table.current_topic(table.id).id == topic.id
  end

end
